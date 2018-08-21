# frozen_string_literal: true

require 'active_support/notifications'

module Traxor
  module Rails
    module ActionMailer
      COUNT_METRIC = 'rails.action_mailer.sent.count'

      def self.record(event)
        tags = { action_mailer_class_name: event.payload[:mailer] }
        Metric.count COUNT_METRIC, 1, tags
      end
    end
  end
end

if Traxor.enabled? && Traxor.scopes.include?(:action_mailer)
  ActiveSupport::Notifications.subscribe 'deliver.action_mailer' do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Traxor::Rails::ActionMailer.record(event)
  end
end
