#!/usr/bin/env ruby

require 'Xcodeproj'


$source_files = {}


class String
  def colorize(color_code) "\e[#{color_code}m#{self}\e[0m" end
  def red; colorize(31) end
  def green; colorize(32) end
  def yellow; colorize(33) end
  def blue; colorize(34) end
  def pink; colorize(35) end
end


def github(repo, branch, options=nil)
  puts "Installing #{repo} (#{branch})".green

  url = 'https://github.com/' + repo
  name = repo.split('/')[1]
  dir = "Mods/#{name}"

  `test -d #{dir} && rm -rf #{dir}; git clone #{url} -b #{branch} #{dir} 2>&1`

  if not options.nil?
    files = options[:files]
    if not files.nil?
      if files.kind_of?(String)
        files = [files]
      end

      files.each do |file|
        absoulte_files = `ls #{dir}/#{file} 2>&1 2>/dev/null`.split(/\r?\n/)
        $source_files[name] = absoulte_files
      end
    end
  end
end


def read_modfile
  begin
    return File.read('Modfile')
  rescue
    puts 'No Modfile.'
    exit 1
  end
end


def install
  mods = read_modfile.split('\r\n')
  mods.each do |line|
    eval line
  end
  generate_project
end


def generate_project
  project_filename_candidates = `ls | grep .xcodeproj`.split(/\r?\n/)
  if project_filename_candidates.length == 0
    puts "Couldn't find .xcodeproj file.".red
    exit 1
  end

  project_filename = project_filename_candidates[0]
  project = Xcodeproj::Project.open(project_filename)

  puts "Configuring #{project_filename}"

  group_mods = project['Mods']
  if not group_mods.nil?
    group_mods.clear
  else
    group_mods = project.new_group('Mods')
  end

  file_references = []

  $source_files.each do |mod, files|
    group_mod = group_mods.new_group(mod)
    files.each do |file|
      added_file = group_mod.new_file(file)
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


case ARGV[0]
  when 'install'
    install
  else
    puts 'Usage: cocoamods install'
end
