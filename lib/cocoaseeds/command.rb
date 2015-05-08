module Seeds
  class Command
    def self.run(argv)
      case argv[0]
      when 'install'
        Seeds::Core.new(Dir.pwd).install
      when '--version'
        puts Seeds::VERSION
      else
        self.help
      end
    end

    def self.help
      puts 'Usage: seed install'
    end
  end
end
