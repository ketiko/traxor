# frozen_string_literal: true

RSpec.describe Traxor::Metric::Line do
  let(:instance) { described_class.new }

  describe '#count' do
    subject(:record_metric) { instance.count('requests', '4') }

    let(:expected_metric_string) { ' count#requests=4 ' }

    it 'logs the metric' do
      expect(instance).to receive(:log).with(expected_metric_string)

      record_metric
      instance.flush
    end
  end

  describe '#measure' do
    subject(:record_metric) { instance.measure('duration', '10ms', a: 1) }

    let(:expected_metric_string) { ' measure#duration=10ms tag#a=1' }

    it 'logs the metric' do
      expect(instance).to receive(:log).with(expected_metric_string)

      record_metric
      instance.flush
    end
  end

  describe '#sample' do
    subject(:record_metric) { instance.sample('memory', '100', b: 2, c: 3) }

    let(:expected_metric_string) { ' sample#memory=100 tag#b=2 tag#c=3' }

    it 'logs the metric' do
      expect(instance).to receive(:log).with(expected_metric_string)

      record_metric
      instance.flush
    end
  end

  describe '#tag_string' do
    subject(:tag_string) { instance.tag_string(tags) }

    let(:tags) { { d: 4, e: 5 } }

    it 'only includes the immediate tags' do
      Thread.new do
        Traxor::Tags.controller = nil
        Traxor::Tags.sidekiq = nil

        expect(tag_string).to eq('tag#d=4 tag#e=5')
      end.join
    end

    it 'uses the global values when present' do
      Thread.new do
        Traxor::Tags.controller = { controller: 1 }
        Traxor::Tags.sidekiq = { sidekiq: 2 }

        expect(tag_string).to include('tag#controller=1')
        expect(tag_string).to include('tag#sidekiq=2')
      end.join
    end
  end

  describe '#normalize_values' do
    module ParentModule
      module ChildModule; end
    end

    subject { instance.normalize_values(value) }

    let(:value) { ParentModule::ChildModule }
    let(:normalized) { 'parent_module.child_module' }

    it { is_expected.to eq(normalized) }
  end

  describe '#log' do
    let(:unformatted) { 'THE::TestThis.a_b' }
    let(:formatted) { 'the.test_this.a_b' }

    it 'logs an info string normalized' do
      expect(instance.logger).to receive(:info).with(formatted)

      instance.log(unformatted)
    end
  end
end
