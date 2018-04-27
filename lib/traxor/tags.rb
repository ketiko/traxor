module Traxor
  module Tags
    CONTROLLER_KEY = 'traxor.action_controller.tags'.freeze
    SIDEKIQ_KEY = 'traxor.sidekiq.tags'.freeze

    def self.all
      controller.merge(sidekiq)
    end

    def self.controller
      Thread.current[CONTROLLER_KEY] || {}
    end

    def self.sidekiq
      Thread.current[SIDEKIQ_KEY] || {}
    end
  end
end
