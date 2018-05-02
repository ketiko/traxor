# frozen_string_literal: true

require 'benchmark'

module Traxor
  class Sidekiq
    DURATION_METRIC = 'sidekiq.worker.duration'
    COUNT_METRIC = 'sidekiq.worker.count'
    EXCEPTION_METRIC = 'sidekiq.worker.exception.count'

    def call(worker, _job, queue)
      tags = Traxor::Tags.sidekiq = { sidekiq_worker: worker.class.name, sidekiq_queue: queue }
      begin
        time = Benchmark.ms { yield }
        Metric.measure DURATION_METRIC, "#{time.round(2)}ms", tags if time.positive?
        Metric.count COUNT_METRIC.freeze, 1, tags
      rescue StandardError
        Metric.count EXCEPTION_METRIC, 1, tags
        raise
      end
    end
  end
end
