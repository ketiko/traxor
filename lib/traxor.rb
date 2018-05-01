require 'logger'
require 'rails'
require 'traxor/metric'
require 'traxor/rails'
require 'traxor/tags'
require 'traxor/version'

module Traxor
  def self.logger
    defined?(@logger) ? @logger : initialize_logger
  end

  def self.initialize_logger(log_target = STDOUT)
    @logger = Logger.new(log_target, level: Logger::INFO, progname: name)
    @logger.formatter = proc do |severity, _time, progname, msg|
      "[#{progname}] #{severity} : #{msg}\n"
    end
    @logger
  end
end
