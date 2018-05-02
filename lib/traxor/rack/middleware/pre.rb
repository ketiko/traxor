require 'traxor/rack/middleware/queue_time'

module Traxor
  module Rack
    module Middleware
      class Pre
        MIDDLEWARE_METRIC = 'rack.request.middleware.duration'.freeze
        DURATION_METRIC = 'rack.request.duration'.freeze
        QUEUE_METRIC = 'rack.request.queue.duration'.freeze
        REQUEST_COUNT_METRIC = 'rack.request.count'.freeze
        GC_DURATION_METRIC = 'ruby.gc.duration'.freeze
        GC_COUNT_METRIC = 'ruby.gc.count'.freeze
        MAJOR_METRIC = 'ruby.gc.major.count'.freeze
        MINOR_METRIC = 'ruby.gc.minor.count'.freeze
        ALLOCATED_METRIC = 'ruby.gc.allocated_objects.count'.freeze

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

          record_request_metrics
          record_gc_metrics

          [status, headers, body]
        end

        def record_request_metrics
          if Middleware.middleware_total.positive?
            Metric.measure MIDDLEWARE_METRIC, "#{Middleware.middleware_total.round(2)}ms"
          end
          if Middleware.request_total.positive?
            Metric.measure DURATION_METRIC, "#{Middleware.request_total.round(2)}ms"
          end
          if Middleware.request_queue_total.positive?
            Metric.measure QUEUE_METRIC, "#{Middleware.request_queue_total.round(2)}ms"
          end
          Metric.count REQUEST_COUNT_METRIC, 1
        end

        def record_gc_metrics
          Metric.measure GC_DURATION_METRIC, "#{(GC::Profiler.total_time * 1_000).to_f.round(2)}ms"
          Metric.count GC_COUNT_METRIC, Middleware.gc_count
          Metric.count MAJOR_METRIC, Middleware.gc_major_count
          Metric.count MINOR_METRIC, Middleware.gc_minor_count
          Metric.count ALLOCATED_METRIC, Middleware.gc_allocated_objects_count

          GC::Profiler.clear
        end
      end
    end
  end
end
