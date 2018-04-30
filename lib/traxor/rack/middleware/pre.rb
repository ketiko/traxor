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
          status, headers, body = @app.call(env)
          Middleware.post_finish_at = Time.now.utc

          record_metrics

          [status, headers, body]
        end

        def record_metrics
          Metric.measure 'rack.request.middleware.duration'.freeze, "#{Middleware.middleware_total.round(2)}ms" if Middleware.middleware_total.positive?
          Metric.measure 'rack.request.duration'.freeze, "#{Middleware.request_total.round(2)}ms" if Middleware.request_total.positive?
          Metric.measure 'rack.request.queue.duration'.freeze, "#{Middleware.request_queue_total.round(2)}ms" if Middleware.request_queue_total.positive?
          Metric.count 'rack.request.count'.freeze, 1
        end
      end
    end
  end
end
