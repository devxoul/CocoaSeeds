require 'colored2'
require 'digest'
require 'fileutils'
require 'xcodeproj'
require 'yaml'
require 'shellwords'

module Seeds
  require 'cocoaseeds/version'
  require 'cocoaseeds/xcodehelper'

  autoload :Command,   'cocoaseeds/command'
  autoload :Core,      'cocoaseeds/core'
  autoload :Exception, 'cocoaseeds/exception'
  autoload :Seed,      'cocoaseeds/seed'
end
