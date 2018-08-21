# frozen_string_literal: true

require 'active_support/notifications'

module Traxor
  module Faraday
    DURATION_METRIC = 'faraday.request.duration'
    COUNT_METRIC = 'faraday.request.count'

    def self.record(event)
      url = event.payload[:url]
      duration = (event.duration || 0.0).to_f
      tags = { faraday_host: url.host, faraday_method: event.payload[:method] }

      Metric.count COUNT_METRIC, 1, tags
      Metric.measure DURATION_METRIC, "#{duration.round(2)}ms", tags if duration.positive?
    end
  end
end

if Traxor.enabled? && Traxor.scopes.include?(:faraday)
  ActiveSupport::Notifications.subscribe('request.faraday') do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Traxor::Faraday.record(event)
  end
end
