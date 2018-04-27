module Traxor
  ActiveSupport::Notifications.subscribe('request.faraday') do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    url = event.payload[:url]
    duration = event.duration || 0.0
    tags = { external_host: url.host, external_method: event.payload[:method] }

    Metric.count 'faraday.request.count', 1, tags
    Metric.measure 'farday.request.duration', "#{duration.to_f.round(2)}ms", tags
  end
end
