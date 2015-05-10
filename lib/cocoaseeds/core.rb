module Seeds
  class Core
    attr_reader :root_path, :seedfile_path, :lockfile_path
    attr_accessor :project, :seedfile, :lockfile
    attr_reader :seeds, :locks, :targets
    attr_reader :source_files, :file_references

    def initialize(root_path)
      @root_path = root_path
      @seedfile_path = File.join(root_path, "Seedfile")
      @lockfile_path = File.join(root_path, "Seeds", "Seedfile.lock")
      @seeds = {}
      @locks = {}
      @targets = {}
      @source_files = {}
      @file_references = []
    end

    def install
      self.prepare_requirements
      self.analyze_dependencies
      self.execute_seedfile
      self.remove_seeds
      self.install_seeds
      self.configure_project
      self.configure_phase
      self.project.save
      self.build_lockfile
      @seeds = {}
      @locks = {}
      @targets = {}
      @source_files = {}
      @file_references = []
    end

    def prepare_requirements
      # .xcodeproj
      project_filename = Dir.glob("#{root_path}/*.xcodeproj")[0]
      if not project_filename
        raise Seeds::Exception.new "Couldn't find .xcodeproj file."
      end
      self.project = Xcodeproj::Project.open(project_filename)

      # Seedfile
      begin
        self.seedfile = File.read(self.seedfile_path)
      rescue Errno::ENOENT
        raise Seeds::Exception.new  "Couldn't find Seedfile."
      end

      # Seedfile.lock - optional
      begin
        self.lockfile = File.read(self.lockfile_path)
      rescue Errno::ENOENT
      end
    end

    def analyze_dependencies
      puts "Anaylizing dependencies"

      # Seedfile.lock
      if self.lockfile
        locks = YAML.load(self.lockfile)
        locks["SEEDS"].each do |lock|
          seed = Seeds::Seed.new
          seed.name = lock.split(' (')[0]
          seed.version = lock.split('(')[1].split(')')[0]
          self.locks[seed.name] = seed
        end
      end
    end

    def execute_seedfile
      def target(*names, &code)
        names.each do |name|
          name = name.to_s  # use string instead of symbol
          @current_target_name = name

          target = self.project.target_named(name)
          if not target
            raise Seeds::Exception.new\
              "#{self.project.path.basename} doesn't have a target `#{name}`"
          end

          code.call()
        end
      end

      def github(repo, tag, options={})
        if not @current_target_name  # apply to all targets
          target *self.project.targets.map(&:name) do
            send(__callee__, repo, tag, options)
          end
          @current_target_name = nil
        else
          seed = Seeds::Seed::GitHub.new
          seed.url = "https://github.com/#{repo}"
          seed.name = repo.split('/')[1]
          seed.version = tag
          seed.files = options[:files] || '**/*.{h,m,mm,swift}'
          if seed.files.kind_of?(String)
            seed.files = [seed.files]
          end
          self.seeds[seed.name] = seed
          self.targets[@current_target_name] ||= []
          self.targets[@current_target_name] << seed
        end
      end

      eval seedfile
      @current_target_name = nil
    end

    def remove_seeds
      removings = self.locks.keys - self.seeds.keys
      removings.each do |name|
        puts "Removing #{name} (#{self.locks[name].version})".red
        dirname = File.join(self.root_path, "Seeds", name)
        FileUtils.rm_rf(dirname)
      end
    end

    def install_seeds
      self.seeds.each do |name, seed|
        dirname = File.join(self.root_path, "Seeds", name)
        if File.exist?(dirname)
          tag = `cd #{dirname} && git describe --tags --abbrev=0 2>&1`
          tag.strip!
          if tag == seed.version
            puts "Using #{name} (#{seed.version})"
          else
            puts "Installing #{name} #{seed.version} (was #{tag})".green
            `cd #{dirname} 2>&1 &&\
             git reset HEAD --hard 2>&1 &&\
             git checkout . 2>&1 &&\
             git clean -fd 2>&1 &&\
             git fetch origin #{seed.version} 2>&1 &&\
             git checkout #{seed.version} 2>&1`
          end
        else
          puts "Installing #{name} (#{seed.version})".green
          output = `git clone #{seed.url} -b #{seed.version} #{dirname} 2>&1`
          if output.include?("not found")
            if output.include?("repository")
              puts "[!] #{name}: Couldn't find the repository.".red
            elsif output.include?("upstream")
              puts "[!] #{name}: Couldn't find the tag `#{seed.version}`.".red
            end
          end
        end

        if seed.files
          seed.files.each do |file|
            self.source_files[name] = Dir.glob(File.join(dirname, file))
          end
        end
      end
    end

    def configure_project
      puts "Configuring #{self.project.path.basename}"

      group = self.project["Seeds"]
      if group
        group.clear
      else
        uuid = Digest::MD5.hexdigest("Seeds").upcase
        group = self.project.new_group_with_uuid("Seeds", uuid)
      end

      # remove existing group that doesn't have any file references
      group.groups.each do |seedgroup|
        valid_files = seedgroup.children.select do |child|
          File.exist?(child.real_path)
        end
        if valid_files.length == 0
          seedgroup.remove_from_project
        end
      end

      self.source_files.each do |seedname, filepaths|
        uuid = Digest::MD5.hexdigest("Seeds/#{seedname}").upcase
        seedgroup = group[seedname] ||
                    group.new_group_with_uuid(seedname, uuid)
        filepaths.each do |path|
          filename = path.split('/')[-1]
          uuid = Digest::MD5.hexdigest(path).upcase
          file_reference = seedgroup[filename] ||
                           seedgroup.new_reference_with_uuid(path, uuid)
          self.file_references << file_reference
        end

        unusing_files = seedgroup.files - self.file_references
        unusing_files.each { |file| file.remove_from_project }
      end
    end

    def configure_phase
      self.targets.each do |target_name, seeds|
        target = self.project.target_named(target_name)
        phase = target.sources_build_phase
        if not phase
          raise Seeds::Exception.new\
            "Target `#{target}` doesn't have build phase 'Compile Sources'."
        end

        # remove zombie file references
        phase.files_references.each do |file_reference|
          begin
            file_reference.real_path
          rescue
            phase.remove_file_reference(file_reference)
          end
        end

        # add file references to sources build phase
        seed_names = seeds.map { |seed| seed.name }
        self.file_references.each do |file|
          if not phase.include?(file) and seed_names.include?(file.parent.name)
            uuid = Digest::MD5.hexdigest("#{target_name}:#{file.name}").upcase
            phase.add_file_reference_with_uuid(file, uuid, true)
          end
        end
      end
    end

    def build_lockfile
      if self.seeds.length > 0
        tree = { "SEEDS" => [] }
        self.seeds.each do |name, seed|
          tree["SEEDS"] << "#{name} (#{seed.version})"
        end
        File.write(self.lockfile_path, YAML.dump(tree))
      end
    end

  end
end
