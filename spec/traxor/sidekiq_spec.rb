# frozen_string_literal: true

require 'traxor/sidekiq'

RSpec.describe Traxor::Sidekiq do
  MockWorker = Class.new
  FakeError = Class.new(StandardError)

  describe '#call' do
    let(:worker) { 'MockWorker' }
    let(:queue) { 'queue' }
    let(:tags) { { sidekiq_worker: worker, sidekiq_queue: queue } }

    context 'when an exception' do
      it 'records exception' do
        Thread.new do
          expect(Traxor::Metric).to receive(:count).with(Traxor::Sidekiq::COUNT_METRIC, 1, tags)
          expect(Traxor::Metric).to receive(:count).with(Traxor::Sidekiq::EXCEPTION_METRIC, 1, tags)
          begin
            described_class.new.call(MockWorker.new, nil, queue) { raise FakeError }
          rescue FakeError
          end

          expect(Traxor::Tags.sidekiq).to eq(tags)
        end.join
      end
    end

    context 'when no exception' do
      it 'records metrics' do
        Thread.new do
          expect(Traxor::Metric).to receive(:measure).with(Traxor::Sidekiq::DURATION_METRIC, any_args, tags)
          expect(Traxor::Metric).to receive(:count).with(Traxor::Sidekiq::COUNT_METRIC, 1, tags)

          described_class.new.call(MockWorker.new, nil, queue) { nil }

          expect(Traxor::Tags.sidekiq).to eq(tags)
        end.join
      end
    end
  end
end
