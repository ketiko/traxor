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
              tags = { controller: controller.class, action: controller.action_name, method: method }
              controller_path = "#{controller.class.to_s.gsub(/::/, '.').underscore}.#{controller.action_name.underscore}.#{method.downcase}"

              Metric.measure "rack.request.duration.middleware.#{controller_path}", "#{middleware_time.round(2)}ms", tags
              Metric.measure "rack.request.duration.#{controller_path}", "#{total_time.round(2)}ms", tags
            end

            Metric.measure 'rack.request.duration.middleware', "#{middleware_time.round(2)}ms", tags
            Metric.measure 'rack.request.duration', "#{total_time.round(2)}ms", tags
          end

          Metric.count 'rack.request.count', 1

          [status, headers, body]
        end
      end
    end
  end
end
