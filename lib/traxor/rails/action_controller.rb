# frozen_string_literal: true

require 'active_support/notifications'

module Traxor
  module Rails
    module ActionController
      COUNT_METRIC = 'rails.action_controller.count'
      TOTAL_METRIC = 'rails.action_controller.total.duration'
      RUBY_METRIC = 'rails.action_controller.ruby.duration'
      DB_METRIC = 'rails.action_controller.db.duration'
      VIEW_METRIC = 'rails.action_controller.view.duration'
      EXCEPTION_METRIC = 'rails.action_controller.exception.count'

      def self.set_controller_tags(event)
        Traxor::Tags.controller = {
          controller_name: event.payload[:controller],
          controller_action: event.payload[:action],
          controller_method: event.payload[:method]
        }
      end

      def self.record(event)
        exception = event.payload[:exception]
        duration = (event.duration || 0.0).to_f
        db_runtime = (event.payload[:db_runtime] || 0.0).to_f
        view_runtime = (event.payload[:view_runtime] || 0.0).to_f
        ruby_runtime = duration - db_runtime - view_runtime

        Metric.count COUNT_METRIC, 1
        Metric.measure TOTAL_METRIC, "#{duration.round(2)}ms" if duration.positive?
        Metric.measure RUBY_METRIC, "#{ruby_runtime.round(2)}ms" if ruby_runtime.positive?
        Metric.measure DB_METRIC, "#{db_runtime.round(2)}ms" if db_runtime.positive?
        Metric.measure VIEW_METRIC, "#{view_runtime.round(2)}ms" if view_runtime.positive?
        Metric.count EXCEPTION_METRIC, 1 if exception
      end
    end
  end
end

if Traxor.enabled? && Traxor.scopes.include?(:action_controller)
  ActiveSupport::Notifications.subscribe 'start_processing.action_controller' do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Traxor::Rails::ActionController.set_controller_tags(event)
  end

  ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Traxor::Rails::ActionController.record(event)
  end
end
