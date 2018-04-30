module Traxor
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
    duration = event.duration || 0.0
    db_runtime = event.payload[:db_runtime] || 0.0
    view_runtime = event.payload[:view_runtime] || 0.0
    ruby_runtime = duration.to_f - db_runtime.to_f - view_runtime.to_f

    Metric.count 'rails.action_controller.count'.freeze, 1
    Metric.measure 'rails.action_controller.total.duration'.freeze, "#{duration.to_f.round(2)}ms"
    Metric.measure 'rails.action_controller.ruby.duration'.freeze, "#{ruby_runtime.to_f.round(2)}ms"
    Metric.measure 'rails.action_controller.db.duration'.freeze, "#{db_runtime.to_f.round(2)}ms"
    Metric.measure 'rails.action_controller.view.duration'.freeze, "#{view_runtime.to_f.round(2)}ms"
    Metric.count 'rails.action_controller.exception.count'.freeze, 1 if exception
  end
end
