require 'active_support'
require 'active_support/core_ext'

require 'mitty/version'
require 'mitty/configuration'
require 'mitty/darkroom'
require 'mitty/publisher'
require 'mitty/cli'

module Mitty

  class << self
    attr_writer :configuration
  end
  
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
