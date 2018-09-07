# frozen_string_literal: true

module Traxor
  module Sidekiq
    class ErrorHandler
      EXCEPTION_METRIC = 'sidekiq.worker.exception.count'

      def call(_ex, context)
        tags = Traxor::Tags.sidekiq = {
          sidekiq_worker: context[:job]['class'],
          sidekiq_queue: context[:job]['queue']
        }
        Metric.count EXCEPTION_METRIC, 1, tags
      end
    end
  end
end
