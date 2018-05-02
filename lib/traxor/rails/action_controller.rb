require 'active_support/notifications'

module Traxor
  module Rails
    module ActionController
      COUNT_METRIC = 'rails.action_controller.count'.freeze
      TOTAL_METRIC = 'rails.action_controller.total.duration'.freeze
      RUBY_METRIC = 'rails.action_controller.ruby.duration'.freeze
      DB_METRIC = 'rails.action_controller.db.duration'.freeze
      VIEW_METRIC = 'rails.action_controller.view.duration'.freeze
      EXCEPTION_METRIC = 'rails.action_controller.exception.count'.freeze

      ActiveSupport::Notifications.subscribe 'start_processing.action_controller'.freeze do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        Traxor::Tags.controller = {
          controller_name: event.payload[:controller],
          controller_action: event.payload[:action],
          controller_method: event.payload[:method]
        }
      end

      ActiveSupport::Notifications.subscribe 'process_action.action_controller'.freeze do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
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
