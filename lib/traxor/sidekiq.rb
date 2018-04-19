require 'traxor/sidekiq/middleware/client'
require 'traxor/sidekiq/middleware/server'

module Traxor
  module Sidekiq
    ::Sidekiq.configure_client do |config|
      config.client_middleware do |chain|
        chain.add Traxor::Sidekiq::Middleware::Client
      end
    end

    ::Sidekiq.configure_server do |config|
      config.client_middleware do |chain|
        chain.add Traxor::Sidekiq::Middleware::Client
      end
      config.server_middleware do |chain|
        chain.add Traxor::Sidekiq::Middleware::Server
      end
    end
  end
end
