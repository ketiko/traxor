# frozen_string_literal: true

require 'traxor/sidekiq'

RSpec.describe Traxor::Sidekiq::Middleware do
  MockWorker = Class.new

  describe '#call' do
    let(:worker) { 'MockWorker' }
    let(:queue) { 'queue' }
    let(:tags) { { sidekiq_worker: worker, sidekiq_queue: queue } }

    it 'records metrics' do
      Thread.new do
        expect_any_instance_of(Traxor::Metric::Line).to(
          receive(:measure).with(Traxor::Sidekiq::Middleware::DURATION_METRIC, any_args, tags)
        )
        expect_any_instance_of(Traxor::Metric::Line).to(
          receive(:count).with(Traxor::Sidekiq::Middleware::COUNT_METRIC, 1, tags)
        )

        described_class.new.call(MockWorker.new, nil, queue) { nil }

        expect(Traxor::Tags.sidekiq).to eq(tags)
      end.join
    end
  end
end
