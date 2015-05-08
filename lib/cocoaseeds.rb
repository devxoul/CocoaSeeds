require 'colorize'
require 'fileutils'
require 'xcodeproj'
require 'yaml'

module Seeds
  require 'cocoaseeds/version'

  autoload :Command,   'cocoaseeds/command'
  autoload :Core,      'cocoaseeds/core'
  autoload :Exception, 'cocoaseeds/exception'
  autoload :Seed,      'cocoaseeds/seed'
end
