module Traxor
  ActiveSupport::Notifications.subscribe 'sql.active_record'.freeze do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    sql = event.payload[:sql].to_s.strip.upcase
    name = event.payload[:name].to_s.strip.upcase
    next if ['SCHEMA'.freeze].any?(name)
    tags = {}
    tags[:active_record_class_name] = name.split.first if name.length.positive?

    Metric.count 'rails.active_record.statements.count'.freeze, 1, tags
    Metric.count 'rails.active_record.statements.select.count'.freeze, 1, tags if sql.starts_with?('SELECT'.freeze)
    Metric.count 'rails.active_record.statements.insert.count'.freeze, 1, tags if sql.starts_with?('INSERT'.freeze)
    Metric.count 'rails.active_record.statements.update.count'.freeze, 1, tags if sql.starts_with?('UPDATE'.freeze)
    Metric.count 'rails.active_record.statements.delete.count'.freeze, 1, tags if sql.starts_with?('DELETE'.freeze)
  end

  ActiveSupport::Notifications.subscribe 'instantiation.active_record'.freeze do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    record_count = event.payload[:record_count]
    tags = { active_record_class_name: event.payload[:class_name] }

    Metric.count 'rails.active_record.instantiation.count'.freeze, record_count, tags
  end
end
