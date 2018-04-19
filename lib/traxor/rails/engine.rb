require 'traxor/rack'

module Traxor
  module Rails
    class Engine < ::Rails::Engine
      initializer 'traxor.setup' do |app|
        Traxor.configure do |config|
          config.logger = ::Rails.logger
        end

        app.config.middleware.insert 0, ::Traxor::Rack::Middleware::Pre
        app.config.middleware.use ::Traxor::Rack::Middleware::Post

        ActiveSupport.on_load :action_controller do
          require 'traxor/rails/action_controller'
        end
        ActiveSupport.on_load :active_record do
          require 'traxor/rails/active_record'
        end
      end
    end
  end
end
