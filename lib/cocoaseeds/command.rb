module Seeds
  class Command
    def self.run(argv)
      case argv[0]
      when 'install'
        begin
          Seeds::Core.new(Dir.pwd).install
        rescue Seeds::Exception => e
          puts "[!] #{e.message}".red
        end
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
