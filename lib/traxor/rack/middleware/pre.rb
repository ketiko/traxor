require 'traxor/rack/middleware/queue_time'

module Traxor
  module Rack
    module Middleware
      class Pre
        def initialize(app)
          @app = app
        end

        def call(env)
          Middleware.request_start_at = QueueTime.parse(env)

          Middleware.pre_start_at = Time.now.utc
          GC::Profiler.enable
          Middleware.gc_stat_before = GC.stat
          status, headers, body = @app.call(env)
          Middleware.gc_stat_after = GC.stat
          Middleware.post_finish_at = Time.now.utc

          record_metrics

          [status, headers, body]
        end

        def record_metrics
          Metric.measure 'rack.request.middleware.duration'.freeze, "#{Middleware.middleware_total.round(2)}ms" if Middleware.middleware_total.positive?
          Metric.measure 'rack.request.duration'.freeze, "#{Middleware.request_total.round(2)}ms" if Middleware.request_total.positive?
          Metric.measure 'rack.request.queue.duration'.freeze, "#{Middleware.request_queue_total.round(2)}ms" if Middleware.request_queue_total.positive?
          Metric.count 'rack.request.count'.freeze, 1

          Metric.measure 'ruby.gc.duration'.freeze, "#{(GC::Profiler.total_time * 1_000).to_f.round(2)}ms"
          Metric.count 'ruby.gc.count'.freeze, Middleware.gc_count
          Metric.count 'ruby.gc.major.count'.freeze, Middleware.gc_major_count
          Metric.count 'ruby.gc.minor.count'.freeze, Middleware.gc_minor_count
          Metric.count 'ruby.gc.allocated_objects.count'.freeze, Middleware.gc_allocated_objects_count

          GC::Profiler.clear
        end
      end
    end
  end
end
