require 'colorize'

module CocoaSeed
  class Command
    def self.run(argv)
      case argv[0]
      when 'install'
        CocoaSeed::Core.new(Dir.pwd).install
      when '--version'
        puts CocoaSeed::VERSION
      else
        self.help
      end
    end

    def self.help
      puts 'Usage: seed install'
    end
  end
end
