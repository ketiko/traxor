module Traxor
  module Rack
    module Middleware
      class Pre
        # any timestamps before this are thrown out and the parser
        # will try again with a larger unit (2000/1/1 UTC)
        EARLIEST_ACCEPTABLE_TIME = Time.at(946684800)

        DIVISORS = [1_000_000, 1_000, 1]

        def initialize(app)
          @app = app
        end

        def call(env)
          env['traxor.rack.middleware.pre_middleware_start'] = Time.now.to_f
          queue_duration = nil
          request_start = env['HTTP_X_REQUEST_START']
          if request_start
            queue_duration = (env['traxor.rack.middleware.pre_middleware_start'].to_f - parse_request_queue(request_start).to_f) * 1_000
          end
          status, headers, body = @app.call(env)
          env['traxor.rack.middleware.post_middleware_end'] = Time.now.to_f

          controller = env['action_controller.instance']
          times = [
            'traxor.rack.middleware.pre_middleware_start',
            'traxor.rack.middleware.pre_middleware_end',
            'traxor.rack.middleware.post_middleware_start',
            'traxor.rack.middleware.post_middleware_end'
          ]

          tags = {}

          if times.all? { |t| env[t].present? }
            pre_time = (env['traxor.rack.middleware.pre_middleware_end'].to_f - env['traxor.rack.middleware.pre_middleware_start'].to_f)
            post_time = (env['traxor.rack.middleware.post_middleware_end'].to_f - env['traxor.rack.middleware.post_middleware_start'].to_f)
            middleware_time = (pre_time + post_time) * 1_000
            total_time = (env['traxor.rack.middleware.post_middleware_end'].to_f - env['traxor.rack.middleware.pre_middleware_start'].to_f) * 1_000

            if controller
              method = env['REQUEST_METHOD'].to_s
              tags = { controller: Traxor.normalize_name(controller.class), action: Traxor.normalize_name(controller.action_name), method: Traxor.normalize_name(method) }
              controller_path = tags.values.join('.')

              Metric.measure 'rack.request.middleware.duration', "#{middleware_time.round(2)}ms", tags
              Metric.measure "rack.request.middleware.duration.#{controller_path}", "#{middleware_time.round(2)}ms", tags
              Metric.measure "rack.request.queue.duration.#{controller_path}", "#{queue_duration.round(2)}ms", tags if queue_duration
              Metric.measure "rack.request.duration.#{controller_path}", "#{total_time.round(2)}ms", tags
              Metric.count "rack.request.count.#{controller_path}", 1, tags
            end

            Metric.measure 'rack.request.duration', "#{total_time.round(2)}ms", tags
          end

          Metric.measure 'rack.request.queue.duration', "#{queue_duration.round(2)}ms", tags if queue_duration
          Metric.count 'rack.request.count', 1, tags

          [status, headers, body]
        end

        def parse_request_queue(string)
          DIVISORS.each do |divisor|
            begin
              t = Time.at(string.to_f / divisor)
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
