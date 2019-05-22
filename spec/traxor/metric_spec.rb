# frozen_string_literal: true

RSpec.describe Traxor::Metric do
  describe '.count' do
    subject(:record_metric) { described_class.count('requests', '4') }

    let(:expected_metric_string) { ' count#requests=4 ' }

    it 'logs the metric' do
      expect_any_instance_of(Traxor::Metric::Line).to receive(:log).with(expected_metric_string)

      record_metric
    end
  end

  describe '.measure' do
    subject(:record_metric) { described_class.measure('duration', '10ms', a: 1) }

    let(:expected_metric_string) { ' measure#duration=10ms tag#a=1' }

    it 'logs the metric' do
      expect_any_instance_of(Traxor::Metric::Line).to receive(:log).with(expected_metric_string)

      record_metric
    end
  end

  describe '.sample' do
    subject(:record_metric) { described_class.sample('memory', '100', b: 2, c: 3) }

    let(:expected_metric_string) { ' sample#memory=100 tag#b=2 tag#c=3' }

    it 'logs the metric' do
      expect_any_instance_of(Traxor::Metric::Line).to receive(:log).with(expected_metric_string)

      record_metric
    end
  end
end
