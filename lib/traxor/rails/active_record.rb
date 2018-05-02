require 'active_support/notifications'

module Traxor
  module Rails
    module ActiveRecord
      COUNT_METRIC = 'rails.active_record.statements.count'.freeze
      SELECT_METRIC = 'rails.active_record.statements.select.count'.freeze
      INSERT_METRIC = 'rails.active_record.statements.insert.count'.freeze
      UPDATE_METRIC = 'rails.active_record.statements.update.count'.freeze
      DELETE_METRIC = 'rails.active_record.statements.delete.count'.freeze
      INSTANTIATION_METRIC = 'rails.active_record.instantiation.count'.freeze

      ActiveSupport::Notifications.subscribe 'sql.active_record'.freeze do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        sql = event.payload[:sql].to_s.strip.upcase
        name = event.payload[:name].to_s.strip.upcase
        next if ['SCHEMA'.freeze].any?(name)
        tags = {}
        tags[:active_record_class_name] = name.split.first if name.length.positive?

        Metric.count COUNT_METRIC, 1, tags
        Metric.count SELECT_METRIC, 1, tags if sql.starts_with?('SELECT'.freeze)
        Metric.count INSERT_METRIC, 1, tags if sql.starts_with?('INSERT'.freeze)
        Metric.count UPDATE_METRIC, 1, tags if sql.starts_with?('UPDATE'.freeze)
        Metric.count DELETE_METRIC, 1, tags if sql.starts_with?('DELETE'.freeze)
      end

      ActiveSupport::Notifications.subscribe 'instantiation.active_record'.freeze do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        record_count = event.payload[:record_count].to_i
        tags = { active_record_class_name: event.payload[:class_name] }

        Metric.count INSTANTIATION_METRIC, record_count, tags if record_count.positive?
      end
    end
  end
end
