module Traxor
  ActiveSupport::Notifications.subscribe 'deliver.action_mailer'.freeze do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    tags = { action_mailer_class_name: event.payload[:mailer] }

    Metric.count 'rails.action_mailer.sent.count'.freeze, 1, tags
  end
end
