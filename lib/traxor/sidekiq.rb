require 'benchmark'

module Traxor
  class Sidekiq
    def call(worker, _job, queue)
      tags = { worker: Traxor.normalize_name(worker.class.name), queue: Traxor.normalize_name(queue) }
      begin
        time = Benchmark.ms do
          yield
        end
        Metric.measure 'sidekiq.worker.duration', "#{time.round(2)}ms", tags
        Metric.measure "sidekiq.worker.duration.#{tags[:worker]}", "#{time.round(2)}ms", tags
        Metric.count 'sidekiq.worker.count', 1, tags
        Metric.count "sidekiq.worker.count.#{tags[:worker]}", 1, tags
      rescue StandardError
        Metric.count 'sidekiq.worker.exception.count', 1, tags
        Metric.count "sidekiq.worker.exception.count.#{tags[:worker]}", 1, tags
        raise
      end
    end
  end
end
