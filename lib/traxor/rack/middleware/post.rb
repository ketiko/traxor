module Traxor
  module Rack
    module Middleware
      class Post
        def initialize(app)
          @app = app
        end

        def call(env)
          env['traxor.rack.middleware.pre_middleware_end'] = Time.now.to_f
          status, headers, response = @app.call(env)
          env['traxor.rack.middleware.post_middleware_start'] = Time.now.to_f

          [status, headers, response]
        end
      end
    end
  end
end
