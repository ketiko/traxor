module Traxor
  module Rack
    module Middleware
      X_REQUEST_START = 'HTTP_X_REQUEST_START'.freeze
      REQUEST_METHOD = 'REQUEST_METHOD'.freeze

      class Pre
        # any timestamps before this are thrown out and the parser
        # will try again with a larger unit (2000/1/1 UTC)
        EARLIEST_ACCEPTABLE_TIME = Time.at(946684800)

        DIVISORS = [1_000_000, 1_000, 1]

        def initialize(app)
          @app = app
        end

        def call(env)
          Thread.current[PRE_MIDDLEWARE_START] = Time.now.to_f
          queue_duration = nil
          request_start = env[X_REQUEST_START]
          if request_start
            parsed = parse_request_queue(request_start)
            queue_duration = (Thread.current[PRE_MIDDLEWARE_START].to_f - parsed.to_f) * 1_000
          end
          status, headers, body = @app.call(env)
          Thread.current[POST_MIDDLEWARE_END] = Time.now.to_f

          times = [
            PRE_MIDDLEWARE_START,
            PRE_MIDDLEWARE_END,
            POST_MIDDLEWARE_START,
            POST_MIDDLEWARE_END
          ]

          if times.all? { |t| Thread.current[t].present? }
            pre_time = (Thread.current[PRE_MIDDLEWARE_END].to_f - Thread.current[PRE_MIDDLEWARE_START].to_f)
            post_time = (Thread.current[POST_MIDDLEWARE_END].to_f - Thread.current[POST_MIDDLEWARE_START].to_f)
            middleware_time = (pre_time + post_time) * 1_000
            total_time = (Thread.current[POST_MIDDLEWARE_END].to_f - Thread.current[PRE_MIDDLEWARE_START].to_f) * 1_000

            if controller_tags = Traxor.controller_tags
              controller_path = controller_tags.values.join('.')

              Metric.measure 'rack.request.middleware.duration', "#{middleware_time.round(2)}ms"
              Metric.measure "rack.request.middleware.duration.#{controller_path}", "#{middleware_time.round(2)}ms"
              Metric.measure "rack.request.queue.duration.#{controller_path}", "#{queue_duration.round(2)}ms" if queue_duration
              Metric.measure "rack.request.duration.#{controller_path}", "#{total_time.round(2)}ms"
              Metric.count "rack.request.count.#{controller_path}", 1
            else
              puts 'missing controller'
            end

            Metric.measure 'rack.request.duration', "#{total_time.round(2)}ms"
          else
            puts 'missing times'
          end

          Metric.measure 'rack.request.queue.duration', "#{queue_duration.round(2)}ms" if queue_duration
          Metric.count 'rack.request.count', 1

          [status, headers, body]
        end

        def parse_request_queue(string)
          value = string.to_s.gsub(/t=/, '')
          DIVISORS.each do |divisor|
            begin
              t = Time.at(value.to_f / divisor)
              return t if t > EARLIEST_ACCEPTABLE_TIME
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
