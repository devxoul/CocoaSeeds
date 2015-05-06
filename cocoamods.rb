#!/usr/bin/env ruby

require 'optparse'
require 'Xcodeproj'


$source_files = {}


def github(repo, branch, options=nil)
  puts "Installing '#{repo}'..."

  url = 'https://github.com/' + repo
  name = repo.split('/')[1]
  dir = "Mods/#{name}"

  # output = `test -d #{dir} && rm -rf #{dir};`
  #          `git clone #{url} -b #{branch} #{dir} 2>&1`

  if not options.nil?
    files = options[:files]
    if not files.nil?
      if files.kind_of?(String)
        files = [files]
      end

      files.each do |file|
        absoulte_files = `ls #{dir}/#{file} 2>&1`.split(/\r?\n/)
        relative_files = absoulte_files.map
        # { |file|
          # file.split('/')[(1..-1)].join('/')
        # }
        $source_files[name] = relative_files
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
    puts "Couldn't find .xcodeproj file."
    exit 1
  end

  project_filename = project_filename_candidates[0]
  project = Xcodeproj::Project.open(project_filename)

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

      file_references.each do |file|
        phase.add_file_reference(file)
      end
    end
  end

  project.save
end


opt_parser = OptionParser.new do |opt|
  opt.banner = 'Usage: cocoapods COMMAND [OPTIONS]'
  opt.separator  ''
  opt.separator  'Commands'
  opt.separator  '     install: install dependencies'
  opt.separator  ''
  opt.separator  'Options'

  opt.on('-h', '--help', 'show this help message.') do
    puts opt_parser
  end
end

opt_parser.parse!

case ARGV[0]
  when 'install'
    install
  else
    puts opt_parser
end
