# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'

module Traxor
  module Sidekiq
    class ErrorHandler
      EXCEPTION_METRIC = 'sidekiq.worker.exception.count'

      def call(_ex, ctx)
        context = ctx.with_indifferent_access
        tags = { sidekiq_worker: context[:job][:class], sidekiq_queue: context[:job][:queue] }
        Metric.count EXCEPTION_METRIC, 1, tags
      end
    end
  end
end
