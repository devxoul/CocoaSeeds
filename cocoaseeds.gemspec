require_relative "lib/cocoaseeds/version"
require "date"

Gem::Specification.new do |s|
  s.name        = "cocoaseeds"
  s.version     = Seeds::VERSION
  s.date        = Date.today
  s.summary     = "Git Submodule Alternative for Cocoa."
  s.description = "Git Submodule Alternative for Cocoa.\n\n"\
                  "iOS 7 projects are not available to use Swift libraries"\
                  "from CocoaPods or Carthage. CocoaSeeds just downloads the"\
                  "source code and add to your Xcode project. No static"\
                  "libraries, no dynamic frameworks at all. It can be used"\
                  "with CocoaPods and Carthage."
  s.authors     = ["Suyeol Jeon"]
  s.email       = "devxoul@gmail.com"
  s.files       = ["lib/cocoaseeds.rb"]
  s.homepage    = "https://github.com/devxoul/CocoaSeeds"
  s.license     = "MIT"

  s.files = Dir["lib/**/*.rb"] + %w{ bin/seed README.md LICENSE }

  s.executables   = %w{ seed }
  s.require_paths = %w{ lib }

  s.add_runtime_dependency "xcodeproj", ">= 0.28"
  s.add_runtime_dependency "colored2", "~> 3.1"

  s.add_development_dependency "rake"

  s.required_ruby_version = ">= 2.2.2"
end
