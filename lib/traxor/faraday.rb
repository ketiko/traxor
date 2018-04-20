module Traxor
  ActiveSupport::Notifications.subscribe('request.faraday') do |name, start_time, end_time, _, env|
    event = ActiveSupport::Notifications::Event.new(*args)
    url = event.payload[:url]
    duration = event.duration || 0.0
    tags = { host: url.host }

    Metric.count 'faraday.request.count', 1, tags
    Metric.measure 'farday.request.duration', "#{duration.to_f.round(2)}ms", tags
  end
end
