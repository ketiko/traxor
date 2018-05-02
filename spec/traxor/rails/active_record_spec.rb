# frozen_string_literal: true

require 'traxor/rails/active_record'

RSpec.describe Traxor::Rails::ActiveRecord do
  describe '.record' do
    let(:now) { Time.now.utc }
    let(:event) do
      ActiveSupport::Notifications::Event.new(
        nil,
        nil,
        nil,
        nil,
        name: 'MyModel',
        sql: nil
      )
    end
    let(:tags) { { active_record_class_name: 'MyModel' } }

    it 'records the metrics' do
      expect(Traxor::Metric).to(
        receive(:count).with(Traxor::Rails::ActiveRecord::COUNT_METRIC, 1, tags)
      )

      described_class.record(event)
    end

    context 'when select' do
      before { event.payload[:sql] = 'select' }

      it 'records the metrics' do
        expect(Traxor::Metric).to(
          receive(:count).with(Traxor::Rails::ActiveRecord::COUNT_METRIC, 1, tags)
        )
        expect(Traxor::Metric).to(
          receive(:count).with(Traxor::Rails::ActiveRecord::SELECT_METRIC, 1, tags)
        )

        described_class.record(event)
      end
    end

    context 'when insert' do
      before { event.payload[:sql] = 'insert' }

      it 'records the metrics' do
        expect(Traxor::Metric).to(
          receive(:count).with(Traxor::Rails::ActiveRecord::COUNT_METRIC, 1, tags)
        )
        expect(Traxor::Metric).to(
          receive(:count).with(Traxor::Rails::ActiveRecord::INSERT_METRIC, 1, tags)
        )

        described_class.record(event)
      end
    end

    context 'when update' do
      before { event.payload[:sql] = 'update' }

      it 'records the metrics' do
        expect(Traxor::Metric).to(
          receive(:count).with(Traxor::Rails::ActiveRecord::COUNT_METRIC, 1, tags)
        )
        expect(Traxor::Metric).to(
          receive(:count).with(Traxor::Rails::ActiveRecord::UPDATE_METRIC, 1, tags)
        )

        described_class.record(event)
      end
    end

    context 'when delete' do
      before { event.payload[:sql] = 'delete' }

      it 'records the metrics' do
        expect(Traxor::Metric).to(
          receive(:count).with(Traxor::Rails::ActiveRecord::COUNT_METRIC, 1, tags)
        )
        expect(Traxor::Metric).to(
          receive(:count).with(Traxor::Rails::ActiveRecord::DELETE_METRIC, 1, tags)
        )

        described_class.record(event)
      end
    end

    context 'when invalid event' do
      before { event.payload[:name] = 'schema' }

      it 'does not record the metrics' do
        expect(Traxor::Metric).not_to(
          receive(:count).with(Traxor::Rails::ActiveRecord::COUNT_METRIC, any_args)
        )
        expect(Traxor::Metric).not_to(
          receive(:count).with(Traxor::Rails::ActiveRecord::COUNT_METRIC, any_args)
        )

        described_class.record(event)
      end
    end

    context 'when missing class name' do
      before { event.payload[:name] = '' }

      it 'does not record the tags' do
        expect(Traxor::Metric).to(
          receive(:count).with(Traxor::Rails::ActiveRecord::COUNT_METRIC, 1, {})
        )

        described_class.record(event)
      end
    end
  end

  describe '.record_instantiations' do
    let(:now) { Time.now.utc }
    let(:event) do
      ActiveSupport::Notifications::Event.new(
        nil,
        nil,
        nil,
        nil,
        record_count: 6,
        class_name: 'MyModel'
      )
    end
    let(:tags) { { active_record_class_name: 'MyModel' } }

    it 'records the metrics' do
      expect(Traxor::Metric).to(
        receive(:count).with(Traxor::Rails::ActiveRecord::INSTANTIATION_METRIC, 6, tags)
      )

      described_class.record_instantiations(event)
    end
  end
end
