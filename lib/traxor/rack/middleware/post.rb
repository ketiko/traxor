module Traxor
  module Rack
    module Middleware
      class Post
        def initialize(app)
          @app = app
        end

        def call(env)
          Middleware.pre_finish_at = Time.now.utc
          status, headers, response = @app.call(env)
          Middleware.post_start_at = Time.now.utc

          [status, headers, response]
        end
      end
    end
  end
end
