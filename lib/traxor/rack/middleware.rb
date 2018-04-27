require 'traxor/rack/middleware/pre'
require 'traxor/rack/middleware/post'

module Traxor
  module Rack
    module Middleware
      PRE_MIDDLEWARE_START = 'traxor.rack.middleware.pre_middleware_start'.freeze
      PRE_MIDDLEWARE_END = 'traxor.rack.middleware.pre_middleware_end'.freeze
      POST_MIDDLEWARE_START = 'traxor.rack.middleware.post_middleware_start'.freeze
      POST_MIDDLEWARE_END = 'traxor.rack.middleware.post_middleware_end'.freeze
    end
  end
end
