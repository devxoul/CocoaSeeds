#!/usr/bin/env ruby

require 'optparse'

def github(repo, branch, options=nil)
  puts "Installing '#{repo}'..."

  url = 'https://github.com/' + repo
  name = repo.split('/')[1]
  dir = "Mods/#{name}"

  output = `test -d #{dir} && rm -rf #{dir};`
           `git clone #{url} -b #{branch} #{dir} 2>&1`

  if !options.nil?
    sources = options[:source]
    if !sources.nil?
      if sources.kind_of?(String)
        sources = [sources]
      end
      puts sources
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
