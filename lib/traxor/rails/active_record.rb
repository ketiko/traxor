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

      def self.record(event)
        sql = event.payload[:sql].to_s.strip.upcase
        name = event.payload[:name].to_s.strip
        return if name.casecmp('SCHEMA').zero?

        tags = {}
        tags[:active_record_class_name] = name.split.first if name.length.positive?

        Metric::Line.record do |l|
          l.count COUNT_METRIC, 1, tags
          l.count SELECT_METRIC, 1, tags if sql.start_with?('SELECT')
          l.count INSERT_METRIC, 1, tags if sql.start_with?('INSERT')
          l.count UPDATE_METRIC, 1, tags if sql.start_with?('UPDATE')
          l.count DELETE_METRIC, 1, tags if sql.start_with?('DELETE')
        end
      end

      def self.record_instantiations(event)
        record_count = event.payload[:record_count].to_i
        tags = { active_record_class_name: event.payload[:class_name] }

        Metric.count INSTANTIATION_METRIC, record_count, tags if record_count.positive?
      end
    end
  end
end

if Traxor.enabled? && Traxor.scopes.include?(:active_record)
  ActiveSupport::Notifications.subscribe 'sql.active_record' do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Traxor::Rails::ActiveRecord.record(event)
  end

  ActiveSupport::Notifications.subscribe 'instantiation.active_record' do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Traxor::Rails::ActiveRecord.record_instantiations(event)
  end
end
