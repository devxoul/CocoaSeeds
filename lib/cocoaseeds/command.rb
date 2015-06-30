require 'json'
require 'net/http'

module Seeds
  class Command
    def self.run(argv)
      case argv[0]
      when 'install'
        begin
          self.check_update
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

    def self.check_update
      begin
        uri = URI('https://api.github.com/'\
                  'repos/devxoul/CocoaSeeds/releases/latest')
        data = JSON(Net::HTTP.get(uri))
        latest = data["tag_name"]
        if VERSION < latest
          puts\
            "\nCocoaSeeds #{latest} is available."\
            " (You're using #{VERSION})\n"\
            "To update: `$ gem install cocoaseeds`\n"\
            "Changelog: https://github.com/devxoul/CocoaSeeds/releases\n".green
        end
      rescue
      end
    end
  end
end
