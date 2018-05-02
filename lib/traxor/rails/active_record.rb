# frozen_string_literal: true

require 'active_support/notifications'

module Traxor
  module Rails
    module ActiveRecord
      COUNT_METRIC = 'rails.active_record.statements.count'
      SELECT_METRIC = 'rails.active_record.statements.select.count'
      INSERT_METRIC = 'rails.active_record.statements.insert.count'
      UPDATE_METRIC = 'rails.active_record.statements.update.count'
      DELETE_METRIC = 'rails.active_record.statements.delete.count'
      INSTANTIATION_METRIC = 'rails.active_record.instantiation.count'

      ActiveSupport::Notifications.subscribe 'sql.active_record' do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        sql = event.payload[:sql].to_s.strip.upcase
        name = event.payload[:name].to_s.strip.upcase
        next if ['SCHEMA'].any?(name)
        tags = {}
        tags[:active_record_class_name] = name.split.first if name.length.positive?

        Metric.count COUNT_METRIC, 1, tags
        Metric.count SELECT_METRIC, 1, tags if sql.starts_with?('SELECT')
        Metric.count INSERT_METRIC, 1, tags if sql.starts_with?('INSERT')
        Metric.count UPDATE_METRIC, 1, tags if sql.starts_with?('UPDATE')
        Metric.count DELETE_METRIC, 1, tags if sql.starts_with?('DELETE')
      end

      ActiveSupport::Notifications.subscribe 'instantiation.active_record' do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        record_count = event.payload[:record_count].to_i
        tags = { active_record_class_name: event.payload[:class_name] }

        Metric.count INSTANTIATION_METRIC, record_count, tags if record_count.positive?
      end
    end
  end
end
