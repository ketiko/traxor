require 'traxor/rack/middleware/pre'
require 'traxor/rack/middleware/post'

module Traxor
  module Rack
    module Middleware
      thread_mattr_accessor :pre_start_at,
                            :pre_finish_at,
                            :post_start_at,
                            :post_finish_at,
                            :request_start_at

      def self.time_before
        return 0 unless pre_start_at

        pre_finish_at.to_f - pre_start_at.to_f
      end

      def self.time_after
        return 0 unless post_start_at

        post_finish_at.to_f - post_start_at.to_f
      end

      def self.middleware_total
        (time_before + time_after) * 1_000
      end

      def self.request_total
        return 0 unless pre_start_at

        (post_finish_at.to_f - pre_start_at.to_f) * 1_000
      end

      def self.request_queue_total
        return 0 unless request_start_at

        (pre_start_at.to_f - request_start_at.to_f) * 1_000
      end
    end
  end
end
