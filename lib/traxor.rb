require 'active_support/core_ext/object/blank'
require 'active_support/inflector/inflections'
require 'logger'
require 'traxor/faraday' if defined?(Faraday)
require 'traxor/metric'
require 'traxor/rack' if defined?(Rack)
require 'traxor/rails' if defined?(Rails::Engine)
require 'traxor/sidekiq' if defined?(Sidekiq)
require 'traxor/tags'
require 'traxor/version'

module Traxor
  def self.logger
    defined?(@logger) ? @logger : initialize_logger
  end

  def self.initialize_logger(log_target = STDOUT)
    @logger = Logger.new(log_target, level: Logger::INFO, progname: name.downcase)
    @logger.formatter = proc do |severity, _time, progname, msg|
      "[#{progname}] #{severity} : #{msg}\n"
    end
    @logger
  end
end
