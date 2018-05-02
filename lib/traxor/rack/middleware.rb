require 'active_support/core_ext/module/attribute_accessors_per_thread'
require 'traxor/rack/middleware/pre'
require 'traxor/rack/middleware/post'

module Traxor
  module Rack
    module Middleware
      thread_mattr_accessor :pre_start_at,
                            :pre_finish_at,
                            :post_start_at,
                            :post_finish_at,
                            :request_start_at,
                            :gc_stat_before,
                            :gc_stat_after

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

      def self.gc_count
        gc_stat_after[:count].to_i - gc_stat_before[:count].to_i
      end

      def self.gc_major_count
        gc_stat_after[:major_gc_count].to_i - gc_stat_before[:major_gc_count].to_i
      end

      def self.gc_minor_count
        gc_stat_after[:minor_gc_count].to_i - gc_stat_before[:minor_gc_count].to_i
      end

      def self.gc_allocated_objects_count
        gc_stat_after[:total_allocated_objects].to_i - gc_stat_before[:total_allocated_objects].to_i
      end
    end
  end
end
