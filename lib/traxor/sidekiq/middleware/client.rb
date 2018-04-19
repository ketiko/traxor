module Traxor
  module Sidekiq
    module Middleware
      class Client
        def call(worker, msg, queue)
          begin
            time = Benchmark.ms do
              yield
            end
            Metric.measure 'sidekiq.worker.enqueue.duration', "#{time.round(2)}ms", worker: worker.class.name
            Metric.measure 'sidekiq.worker.enqueue.count', 1, worker: worker.class.name
          rescue StandardError => ex
            Metric.count 'sidekiq.worker.enqueue.exception.count', 1, worker: worker.class.name
            raise
          end
        end
      end
    end
  end
end
