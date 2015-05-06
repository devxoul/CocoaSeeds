require 'date'

Gem::Specification.new do |s|
  s.name        = 'cocoaseeds'
  s.version     = '0.0.1'
  s.date        = Date.today
  s.summary     = "Git Submodule Alternative for Cocoa."
  s.description = "Git Submodule Alternative for Cocoa."
  s.authors     = ["Suyeol Jeon"]
  s.email       = 'devxoul@gmail.com'
  s.files       = ["lib/cocoaseeds.rb"]
  s.homepage    = 'https://github.com/devxoul/CocoaSeeds'
  s.license     = 'MIT'
  s.executables << 'seed'
end
