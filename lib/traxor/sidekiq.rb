require 'benchmark'

module Traxor
  class Sidekiq
    def call(worker, _job, queue)
      tags = Thread.current[SIDEKIQ_TAGS] = { sidekiq_worker: worker.class.name, sidekiq_queue: queue }
      begin
        time = Benchmark.ms do
          yield
        end
        Metric.measure 'sidekiq.worker.duration', "#{time.round(2)}ms", tags
        Metric.count 'sidekiq.worker.count', 1, tags
      rescue StandardError
        Metric.count 'sidekiq.worker.exception.count', 1, tags
        raise
      end
    end
  end
end
