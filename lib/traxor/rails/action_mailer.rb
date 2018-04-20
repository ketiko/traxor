module Traxor
  ActiveSupport::Notifications.subscribe 'deliver.action_mailer' do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    tags = { mailer: normalize_name(event.payload[:mailer]) }

    Metric.count 'rails.action_mailer.sent.count', 1, tags
    Metric.count "rails.action_mailer.sent.count.#{tags[:mailer]}", 1, tags
  end
end
