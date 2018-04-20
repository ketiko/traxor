module Traxor
  ActiveSupport::Notifications.subscribe('request.faraday') do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    url = event.payload[:url]
    duration = event.duration || 0.0
    tags = { host: normalize_name(url.host), method: normalize_name(event.payload[:method]) }

    Metric.count 'faraday.request.count', 1, tags
    Metric.count "faraday.request.count.#{tags[:host]}", 1, tags
    Metric.measure 'farday.request.duration', "#{duration.to_f.round(2)}ms", tags
    Metric.measure "farday.request.duration.#{tags[:host]}", "#{duration.to_f.round(2)}ms", tags
  end
end
