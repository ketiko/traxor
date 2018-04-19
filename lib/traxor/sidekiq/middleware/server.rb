require 'benchmark'

module Traxor
  module Sidekiq
    module Middleware
      class Server
        def call(worker, job, queue)
          begin
            time = Benchmark.ms do
              yield
            end
            Metric.measure 'sidekiq.worker.dequeue.duration', "#{time.round(2)}ms", worker: worker.class.name
            Metric.measure 'sidekiq.worker.dequeue.count', 1, worker: worker.class.name
          rescue StandardError => ex
            Metric.count 'sidekiq.worker.dequeue.exception.count', 1, worker: worker.class.name
            raise
          end
        end
      end
    end
  end
end
