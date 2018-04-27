module Traxor
  module Rack
    module Middleware
      X_REQUEST_START = 'HTTP_X_REQUEST_START'.freeze
      REQUEST_METHOD = 'REQUEST_METHOD'.freeze

      class Pre
        # any timestamps before this are thrown out and the parser
        # will try again with a larger unit (2000/1/1 UTC)
        EARLIEST_ACCEPTABLE_TIME = Time.at(946_684_800).utc

        DIVISORS = [1_000_000, 1_000, 1].freeze

        def initialize(app)
          @app = app
        end

        def call(env)
          Middleware.pre_start_at = Time.now.utc
          status, headers, body = @app.call(env)
          Middleware.post_finish_at = Time.now.utc

          times = [
            Middleware.pre_start_at,
            Middleware.pre_finish_at,
            Middleware.post_start_at,
            Middleware.post_finish_at,
          ]

          if times.all?
            Metric.measure 'rack.request.middleware.duration'.freeze, "#{Middleware.total.round(2)}ms"
            Metric.measure 'rack.request.duration'.freeze, "#{Middleware.request_total.round(2)}ms"
          end

          if env[X_REQUEST_START]
            parsed = parse_request_queue(env[X_REQUEST_START])
            queue_duration = (Middleware.pre_start_at.to_f - parsed.to_f) * 1_000
            Metric.measure 'rack.request.queue.duration'.freeze, "#{queue_duration.round(2)}ms" if queue_duration
          end

          Metric.count 'rack.request.count'.freeze, 1

          [status, headers, body]
        end

        def parse_request_queue(string)
          value = string.to_s.sub(/t=/, ''.freeze)
          DIVISORS.each do |divisor|
            begin
              time = Time.at(value.to_f / divisor).utc
              return time if time > EARLIEST_ACCEPTABLE_TIME
            rescue RangeError
              # On Ruby versions built with a 32-bit time_t, attempting to
              # instantiate a Time object in the far future raises a RangeError,
              # in which case we know we've chosen the wrong divisor.
            end
          end

          nil
        end
      end
    end
  end
end
