require 'active_support/configurable'
require 'active_support/inflector/inflections'
require 'logger'
require 'traxor/metric'
require 'traxor/rails' if defined?(Rails)
require 'traxor/sidekiq' if defined?(Sidekiq)
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

  def self.normalize_name(value)
    value.to_s.gsub(/::/, '.').underscore
  end
end
