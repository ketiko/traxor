require 'active_support/configurable'
require 'logger'
require 'traxor/metric'
require 'traxor/rails' if defined?(Rails)
require 'traxor/version'

module Traxor
  include ActiveSupport::Configurable
  config_accessor :logger do
    Logger.new(STDOUT).tap do |l|
      l.level = Logger::INFO
    end
  end

  def self.configure
    yield config
  end
end
