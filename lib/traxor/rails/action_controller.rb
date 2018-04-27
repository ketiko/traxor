module Traxor
  ActiveSupport::Notifications.subscribe 'start_processing.action_controller' do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Thread.current[CONTROLLER_TAGS] = {
      controller_name: Traxor.normalize_name(event.payload[:controller]),
      controller_action: Traxor.normalize_name(event.payload[:action]),
      controller_method: Traxor.normalize_name(event.payload[:method])
    }
  end

  ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    request = ActionDispatch::Request.new(event.payload[:headers])
    exception = event.payload[:exception]
    duration = event.duration || 0.0
    db_runtime = event.payload[:db_runtime] || 0
    view_runtime = event.payload[:view_runtime] || 0
    ruby_runtime = duration.to_f - db_runtime.to_f - view_runtime.to_f

    tags = Traxor.controller_tags
    controller_path = tags.values.join(' ') if tags.keys.count.positive?

    Metric.count 'rails.action_controller.count', 1, tags
    Metric.count "rails.action_controller.count.#{controller_path}", 1, tags if controller_path

    Metric.measure 'rails.action_controller.total.duration', "#{duration.to_f.round(2)}ms", tags
    Metric.measure "rails.action_controller.total.duration.#{controller_path}", "#{duration.to_f.round(2)}ms", tags if controller_path

    Metric.measure 'rails.action_controller.ruby.duration', "#{ruby_runtime.to_f.round(2)}ms", tags
    Metric.measure "rails.action_controller.ruby.duration.#{controller_path}", "#{ruby_runtime.to_f.round(2)}ms", tags if controller_path

    Metric.measure 'rails.action_controller.db.duration', "#{db_runtime.to_f.round(2)}ms", tags
    Metric.measure "rails.action_controller.db.duration.#{controller_path}", "#{db_runtime.to_f.round(2)}ms", tags if controller_path

    Metric.measure 'rails.action_controller.view.duration', "#{view_runtime.to_f.round(2)}ms", tags
    Metric.measure "rails.action_controller.view.duration.#{controller_path}", "#{view_runtime.to_f.round(2)}ms", tags if controller_path

    if exception.present?
      Metric.count 'rails.action_controller.exception.count', 1, tags
      Metric.count "rails.action_controller.exception.count.#{controller_path}", 1, tags if controller_path
    end
  end
end
