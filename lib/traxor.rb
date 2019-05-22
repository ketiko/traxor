# frozen_string_literal: true

require 'logger'
require 'active_support/core_ext/object/blank'

module Traxor
  DEFAULT_SCOPES = 'rack,action_controller,action_mailer,active_record,faraday,sidekiq'

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

  def self.enabled?
    ENV['DISABLE_TRAXOR'].blank?
  end

  def self.scopes
    @scopes ||= ENV
                .fetch('TRAXOR_SCOPES', DEFAULT_SCOPES)
                .to_s
                .downcase
                .split(',')
                .map(&:strip)
                .map(&:chomp)
                .map(&:to_sym)
  end
end

require 'traxor/faraday' if defined?(Faraday)
require 'traxor/metric'
require 'traxor/rack' if defined?(Rack)
require 'traxor/rails' if defined?(Rails::Engine)
require 'traxor/sidekiq' if defined?(Sidekiq)
require 'traxor/tags'
require 'traxor/version'
