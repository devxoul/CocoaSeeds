require File.expand_path('../lib/cocoaseeds/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'cocoaseeds'
  s.version     = Seed::VERSION
  s.date        = Date.today
  s.summary     = "Git Submodule Alternative for Cocoa."
  s.description = "Git Submodule Alternative for Cocoa."
  s.authors     = ["Suyeol Jeon"]
  s.email       = 'devxoul@gmail.com'
  s.files       = ["lib/cocoaseeds.rb"]
  s.homepage    = 'https://github.com/devxoul/CocoaSeeds'
  s.license     = 'MIT'

  s.files = Dir["lib/**/*.rb"] + %w{ bin/seed README.md LICENSE }

  s.executables   = %w{ seed }
  s.require_paths = %w{ lib }

  s.add_runtime_dependency 'xcodeproj', '~> 0.24.1'
  s.add_runtime_dependency 'colorize', '~> 0.7.7'
  s.required_ruby_version = '>= 2.0.0'
end
