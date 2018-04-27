require 'traxor/rack'

module Traxor
  class Rails < ::Rails::Engine
    initializer 'traxor.setup' do |app|
      Traxor.configure do |config|
        if ::Rails.env.development? || ::Rails.env.test?
          orig = Traxor.config.logger
          config.logger = Logger.new(::Rails.root.join('log', 'traxor.log')).tap do |logger|
            logger.progname = orig.progname
            logger.formatter = orig.formatter
            logger.level = orig.level
          end
        end
      end

      app.config.middleware.insert 0, Traxor::Rack::Middleware::Pre
      app.config.middleware.use Traxor::Rack::Middleware::Post

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

    config.before_configuration do
      require 'traxor/faraday' if defined?(Faraday)

      if defined?(Sidekiq)
        ::Sidekiq.server_middleware do |chain|
          require 'traxor/sidekiq'
          chain.add Traxor::Sidekiq
        end
      end
    end
  end
end
