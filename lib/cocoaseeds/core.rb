module Seed
  class Core
    @source_files = {}

    def self.install
      seeds = read_seedfile.split('\r\n')
      seeds.each { |line| eval line }
      self.configure_project
    end

    def self.read_seedfile
      begin
        File.read('Seedfile')
      rescue
        puts 'No Seedfile.'
        exit 1
      end
    end

    def self.github(repo, tag, options=nil)
      url = "https://github.com/#{repo}"
      name = repo.split('/')[1]
      dir = "Seeds/#{name}"

      if File.exist?(dir)
        current_tag = `cd #{dir} && git describe --tags --abbrev=0 2>&1`
        current_tag.strip!
        if current_tag == tag
          puts "Using #{name} (#{tag})"
        else
          puts "Installing #{name} #{tag} (was #{current_tag})".green
          `cd #{dir} 2>&1 &&\
           git reset HEAD --hard 2>&1 &&\
           git checkout . 2>&1 &&\
           git clean -fd 2>&1 &&\
           git fetch origin #{tag} 2>&1 &&\
           git checkout #{tag} 2>&1`
        end
      else
        puts "Installing #{name} (#{tag})".green
        `git clone #{url} -b #{tag} #{dir} 2>&1`
      end

      if not options.nil?
        files = options[:files]
        if not files.nil?
          if files.kind_of?(String)
            files = [files]
          end

          files.each do |file|
            file_list = `ls #{dir}/#{file} 2>&1 2>/dev/null`
            absoulte_files = file_list.split(/\r?\n/)
            @source_files[name] = absoulte_files
          end
        end
      end

      if not @source_files[name]
        @source_files[name] = dir
      end
    end

    def self.configure_project
      # detect Xcode project
      project_filename = `ls | grep .xcodeproj`.split(/\r?\n/)[0]
      if not project_filename
        puts "Couldn't find .xcodeproj file.".red
        exit 1
      end

      puts "Configuring #{project_filename}"
      project = Xcodeproj::Project.open(project_filename)

      file_references = self.configure_group(project)
      self.configure_phase(project, file_references)

      project.save
    end

    def self.configure_group(project)
      # prepare group 'Seeds'
      group = project['Seeds']
      if not group.nil?
        group.clear
      else
        group = project.new_group('Seeds')
      end

      # add source files to group
      file_references = []
      @source_files.each do |seedname, files|
        seedgroup = group.new_group(seedname)
        files.each { |file| file_references << seedgroup.new_file(file) }
      end
    end

    def self.configure_phase(project, file_references)
      targets = project.targets.select { |t| not t.name.end_with?('Tests') }
      targets.each do |target|
        # detect source build phase
        phase = target.build_phases.each do |phase|
          if phase.kind_of?(Xcodeproj::Project::Object::PBXSourcesBuildPhase)
            return phase
          end
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
        file_references.each do |file|
          if not phase.include?(file)
            phase.add_file_reference(file)
          end
        end
      end
    end
  end
end
