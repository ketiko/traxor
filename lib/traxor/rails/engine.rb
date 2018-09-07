# frozen_string_literal: true

require 'rails/engine'

module Traxor
  module Rails
    class Engine < ::Rails::Engine
      initializer 'traxor.setup' do |app|
        if ::Rails.env.development? || ::Rails.env.test?
          Traxor.initialize_logger(::Rails.root.join('log', 'traxor.log'))
        end

        if Traxor.enabled?
          if Traxor.scopes.include?(:rack)
            require 'traxor/rack'
            app.config.middleware.insert 0, Traxor::Rack::Middleware::Pre
            app.config.middleware.use Traxor::Rack::Middleware::Post
          end

          ActiveSupport.on_load :action_controller do
            require 'traxor/rails/action_controller'
          end
          ActiveSupport.on_load :active_record do
            require 'traxor/rails/active_record'
          end
          ActiveSupport.on_load :action_mailer do
            require 'traxor/rails/action_mailer'
          end
        end
      end

      config.before_configuration do
        if Traxor.enabled?
          require 'traxor/faraday' if defined?(Faraday)

          if defined?(Sidekiq) && Traxor.scopes.include?(:sidekiq)
            require 'traxor/sidekiq'
            ::Sidekiq.server_middleware do |chain|
              chain.add Traxor::Sidekiq::Middleware
            end

            ::Sidekiq.configure_server do |config|
              config.error_handlers << Traxor::Sidekiq::ErrorHandler.new
            end
          end
        end
      end
    end
  end
end
