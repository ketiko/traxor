module Traxor
  ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    request = ActionDispatch::Request.new(event.payload[:headers])
    exception = event.payload[:exception]
    controller = normalize_name(event.payload[:controller])
    action = normalize_name(event.payload[:action])
    duration = event.duration || 0.0
    db_runtime = event.payload[:db_runtime] || 0
    view_runtime = event.payload[:view_runtime] || 0
    ruby_runtime = duration.to_f - db_runtime.to_f - view_runtime.to_f

    controller_path = normalize_name("#{controller.underscore}.#{action.underscore}.#{request.method.downcase}")
    tags = { controller: controller, action: action, method: normalize_name(request.method) }

    Metric.count 'rails.action_controller.count', 1, tags
    Metric.count "rails.action_controller.count.#{controller_path}", 1, tags

    Metric.measure 'rails.action_controller.ruby.duration', "#{ruby_runtime.to_f.round(2)}ms", tags
    Metric.measure "rails.action_controller.ruby.duration.#{controller_path}", "#{ruby_runtime.to_f.round(2)}ms", tags

    Metric.measure 'rails.action_controller.db.duration', "#{db_runtime.to_f.round(2)}ms", tags
    Metric.measure "rails.action_controller.db.duration.#{controller_path}", "#{db_runtime.to_f.round(2)}ms", tags

    Metric.measure 'rails.action_controller.view.duration', "#{view_runtime.to_f.round(2)}ms", tags
    Metric.measure "rails.action_controller.view.duration.#{controller_path}", "#{view_runtime.to_f.round(2)}ms", tags

    if exception.present?
      Metric.count 'rails.action_controller.exception.count', 1, tags
      Metric.count "rails.action_controller.exception.count.#{controller_path}", 1, tags
    end
  end
end
