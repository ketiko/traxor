module Traxor
  ActiveSupport::Notifications.subscribe('request.faraday'.freeze) do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    url = event.payload[:url]
    duration = event.duration || 0.0
    tags = { external_lib: 'faraday'.freeze, external_host: url.host, external_method: event.payload[:method] }

    Metric.count 'external.request.count'.freeze, 1, tags
    Metric.measure 'external.request.duration'.freeze, "#{duration.to_f.round(2)}ms", tags
  end
end
