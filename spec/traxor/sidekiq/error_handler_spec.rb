# frozen_string_literal: true

require 'traxor/sidekiq'

RSpec.describe Traxor::Sidekiq::ErrorHandler do
  describe '#call' do
    let(:ctx) do
      {
        job: {
          'class' => worker,
          'queue' => queue
        }
      }
    end
    let(:worker) { 'MockWorker' }
    let(:queue) { 'queue' }
    let(:tags) { { sidekiq_worker: worker, sidekiq_queue: queue } }

    it 'records exception' do
      expect(Traxor::Metric).to(
        receive(:count).with(Traxor::Sidekiq::ErrorHandler::EXCEPTION_METRIC, 1, tags)
      )
      described_class.new.call(nil, ctx)
    end
  end
end
