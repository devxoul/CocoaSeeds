module Seeds
  class Core
    attr_accessor :mute

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
      say "Anaylizing dependencies"

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
      @current_target_name = nil

      def target(*names, &code)
        names.each do |name|
          name = name.to_s  # use string instead of symbol
          target = self.project.target_named(name)
          if not target
            raise Seeds::Exception.new\
              "#{self.project.path.basename} doesn't have a target `#{name}`"
          end

          @current_target_name = name
          code.call()
        end
        @current_target_name = nil
      end

      def github(repo, tag, options={})
        if not @current_target_name  # apply to all targets
          target *self.project.targets.map(&:name) do
            send(__callee__, repo, tag, options)
          end
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
          self.targets[seed.name] ||= []
          self.targets[seed.name] << @current_target_name.to_s
        end
      end

      eval seedfile
    end

    def remove_seeds
      removings = self.locks.keys - self.seeds.keys
      removings.each do |name|
        say "Removing #{name} (#{self.locks[name].version})".red
        dirname = File.join(self.root_path, "Seeds", name)
        FileUtils.rm_rf(dirname)
      end
    end

    def install_seeds
      self.seeds.sort.each do |name, seed|
        dirname = File.join(self.root_path, "Seeds", name)
        if File.exist?(dirname)
          tag = `cd #{dirname} && git describe --tags --abbrev=0 2>&1`
          tag.strip!
          if tag == seed.version
            say "Using #{name} (#{seed.version})"
          else
            say "Installing #{name} #{seed.version} (was #{tag})".green
            `cd #{dirname} 2>&1 &&\
             git reset HEAD --hard 2>&1 &&\
             git checkout . 2>&1 &&\
             git clean -fd 2>&1 &&\
             git fetch origin #{seed.version} 2>&1 &&\
             git checkout #{seed.version} 2>&1`
          end
        else
          say "Installing #{name} (#{seed.version})".green
          output = `git clone #{seed.url} -b #{seed.version} #{dirname} 2>&1`
          if output.include?("not found")
            if output.include?("repository")
              say "[!] #{name}: Couldn't find the repository.".red
            elsif output.include?("upstream")
              say "[!] #{name}: Couldn't find the tag `#{seed.version}`.".red
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
      say "Configuring #{self.project.path.basename}"

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
      self.project.targets.each do |target|
        phase = target.sources_build_phase
        next if not phase

        # remove zombie build files
        phase.files_references.each do |file|
          begin
            file.real_path
          rescue
            phase.files.each do |build_file|
              phase.files.delete(build_file) if build_file.file_ref == file
            end
          end
        end

        removings = [] # name of seeds going to be removed from the target
        addings = [] # name of seeds going to be added to the target

        self.targets.keys.sort.each do |seed_name|
          target_names = self.targets[seed_name]
          if not target_names.include?(target.name)
            removings << seed_name if not removings.include?(seed_name)
          else
            addings << seed_name if not addings.include?(seed_name)
          end
        end

        self.file_references.each do |file|
          removings.each do |seed_names|
            next if not seed_names.include?(file.parent.name)
            phase.files.each do |build_file|
              phase.files.delete(build_file) if build_file.file_ref == file
            end
          end

          addings.each do |seed_names|
            next if not seed_names.include?(file.parent.name)
            uuid = Digest::MD5.hexdigest("#{target.name}:#{file.name}").upcase
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

    def say(*strings)
      puts strings.join(" ") if not @mute
    end

  end
end
