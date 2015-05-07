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

    def self.github(repo, branch, options=nil)
      puts "Installing #{repo} (#{branch})".green

      url = "https://github.com/#{repo}"
      name = repo.split('/')[1]
      dir = "Seeds/#{name}"

      `test -d #{dir} && rm -rf #{dir};`
      `git clone #{url} -b #{branch} #{dir} 2>&1`

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

    def self.project_filename
      `ls | grep .xcodeproj`.split(/\r?\n/)[0]
    end

    def self.configure_project
      project_filename_candidates = `ls | grep .xcodeproj`.split(/\r?\n/)
      if project_filename_candidates.length == 0
        puts "Couldn't find .xcodeproj file.".red
        exit 1
      end

      project_filename = self.project_filename
      if not project_filename
        puts "Couldn't find .xcodeproj file.".red
        exit 1
      end

      puts "Configuring #{project_filename}"
      project = Xcodeproj::Project.open(project_filename)

      group_seeds = project['Seeds']
      if not group_seeds.nil?
        group_seeds.clear
      else
        group_seeds = project.new_group('Seeds')
      end

      file_references = []

      @source_files.each do |seed, files|
        group_seed = group_seeds.new_group(seed)
        files.each do |file|
          added_file = group_seed.new_file(file)
          file_references.push(added_file)
        end
      end

      project.targets.each do |target|
        if project.targets.length > 1 and target.name.end_with?('Tests')
          next
        end

        target.build_phases.each do |phase|
          if not phase.kind_of?(Xcodeproj::Project::Object::PBXSourcesBuildPhase)
            next
          end

          phase.files_references.each do |file_reference|
            begin
              file_reference.real_path
            rescue
              phase.remove_file_reference(file_reference)
            end
          end

          file_references.each do |file|
            if not phase.include?(file)
              phase.add_file_reference(file)
            end
          end
        end
      end

      project.save
      puts "Done."
    end
  end
end