require 'colorize'
require 'digest'
require 'fileutils'
require 'xcodeproj'
require 'yaml'

module Seeds
  require 'cocoaseeds/version'
  require_relative 'cocoaseeds/xcodehelper'

  autoload :Command,   'cocoaseeds/command'
  autoload :Core,      'cocoaseeds/core'
  autoload :Exception, 'cocoaseeds/exception'
  autoload :Seed,      'cocoaseeds/seed'
end
