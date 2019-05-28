# frozen_string_literal: true

require 'active_support/core_ext/benchmark'

module Traxor
  module Sidekiq
    class Middleware
      DURATION_METRIC = 'sidekiq.worker.duration'
      COUNT_METRIC = 'sidekiq.worker.count'

      def call(worker, _job, queue)
        tags = Traxor::Tags.sidekiq = { sidekiq_worker: worker.class.name, sidekiq_queue: queue }
        Metric::Line.record do |l|
          l.count COUNT_METRIC, 1, tags
          time = Benchmark.ms { yield }
          l.measure DURATION_METRIC, "#{time.round(2)}ms", tags if time.positive?
        end
      end
    end
  end
end
