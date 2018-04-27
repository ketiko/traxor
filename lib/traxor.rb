require 'active_support/configurable'
require 'active_support/inflector/inflections'
require 'active_support/core_ext/object/blank'
require 'logger'
require 'traxor/faraday' if defined?(Faraday)
require 'traxor/metric'
require 'traxor/rack' if defined?(Rack)
require 'traxor/rails' if defined?(Rails)
require 'traxor/sidekiq' if defined?(Sidekiq)
require 'traxor/version'

module Traxor
  include ActiveSupport::Configurable

  CONTROLLER_TAGS = 'traxor.action_controller.tags'.freeze
  SIDEKIQ_TAGS = 'traxor.sidekiq.tags'.freeze

  config_accessor :logger do
    Logger.new(STDOUT, progname: 'traxor', level: Logger::INFO).tap do |logger|
      logger.formatter = proc do |severity, time, progname, msg|
        "[#{progname}] #{severity} : #{msg}\n"
      end
    end
  end

  def self.configure
    yield config
  end

  def self.normalize_name(value)
    value.to_s.gsub(/::/, '.').underscore
  end

  def self.controller_tags
    Thread.current[CONTROLLER_TAGS] || {}
  end

  def self.sidekiq_tags
    Thread.current[SIDEKIQ_TAGS] || {}
  end

  def self.current_tags
    controller_tags.merge(sidekiq_tags)
  end
end
