module Traxor
  module Rack
    module Middleware
      class Pre
        def initialize(app)
          @app = app
        end

        def call(env)
          env['traxor.rack.middleware.pre_middleware_start'] = Time.now.to_f
          status, headers, body = @app.call(env)
          env['traxor.rack.middleware.post_middleware_end'] = Time.now.to_f

          controller = env['action_controller.instance']
          times = [
            'traxor.rack.middleware.pre_middleware_start',
            'traxor.rack.middleware.pre_middleware_end',
            'traxor.rack.middleware.post_middleware_start',
            'traxor.rack.middleware.post_middleware_end'
          ]

          if times.all? { |t| env[t].present? }
            pre_time = (env['traxor.rack.middleware.pre_middleware_end'].to_f - env['traxor.rack.middleware.pre_middleware_start'].to_f)
            post_time = (env['traxor.rack.middleware.post_middleware_end'].to_f - env['traxor.rack.middleware.post_middleware_start'].to_f)
            middleware_time = (pre_time + post_time) * 1_000
            total_time = (env['traxor.rack.middleware.post_middleware_end'].to_f - env['traxor.rack.middleware.pre_middleware_start'].to_f) * 1_000

            tags = {}
            if controller
              method = env['REQUEST_METHOD'].to_s
              tags = { controller: Traxor.normalize_name(controller.class), action: Traxor.normalize_name(controller.action_name), method: Traxor.normalize_name(method) }
              controller_path = tags.values.join('.')

              Metric.measure "rack.request.middleware.duration.#{controller_path}", "#{middleware_time.round(2)}ms", tags
              Metric.measure "rack.request.duration.#{controller_path}", "#{total_time.round(2)}ms", tags
              Metric.count 'rack.request.count', 1, tags
              Metric.count "rack.request.count.#{controller_path}", 1, tags
            end

            Metric.measure 'rack.request.middleware.duration', "#{middleware_time.round(2)}ms", tags
            Metric.measure 'rack.request.duration', "#{total_time.round(2)}ms", tags
          end

          Metric.count 'rack.request.count', 1

          [status, headers, body]
        end
      end
    end
  end
end
