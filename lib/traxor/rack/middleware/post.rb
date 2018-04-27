module Traxor
  module Rack
    module Middleware
      class Post
        def initialize(app)
          @app = app
        end

        def call(env)
          Thread.current[PRE_MIDDLEWARE_END] = Time.now.to_f
          status, headers, response = @app.call(env)
          Thread.current[POST_MIDDLEWARE_START] = Time.now.to_f

          [status, headers, response]
        end
      end
    end
  end
end
