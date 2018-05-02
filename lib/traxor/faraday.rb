require 'active_support/notifications'

module Traxor
  module Faraday
    ActiveSupport::Notifications.subscribe('request.faraday'.freeze) do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      url = event.payload[:url]
      duration = (event.duration || 0.0).to_f
      tags = { faraday_host: url.host, faraday_method: event.payload[:method] }

      Metric.count 'faraday.request.count'.freeze, 1, tags
      Metric.measure 'faraday.request.duration'.freeze, "#{duration.round(2)}ms", tags if duration.positive?
    end
  end
end
