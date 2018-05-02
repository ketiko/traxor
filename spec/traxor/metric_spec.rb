RSpec.describe Traxor::Metric do
  describe '.count' do
    subject(:record_metric) { described_class.count('requests', '4') }

    let(:fake_logger) { instance_double(Logger).as_null_object }

    before do
      allow(described_class).to receive(:logger).and_return(fake_logger)
    end

    let(:expected_metric_string) { 'count#requests=4' }

    it 'logs the metric' do
      record_metric

      expect(fake_logger).to have_received(:info).with(expected_metric_string)
    end
  end

  describe '.measure' do
    subject(:record_metric) { described_class.measure('duration', '10ms', a: 1) }

    let(:fake_logger) { instance_double(Logger).as_null_object }
    let(:expected_metric_string) { 'measure#duration=10ms tag#a=1' }

    before do
      allow(described_class).to receive(:logger).and_return(fake_logger)
    end

    it 'logs the metric' do
      record_metric

      expect(fake_logger).to have_received(:info).with(expected_metric_string)
    end
  end

  describe '.sample' do
    subject(:record_metric) { described_class.sample('memory', '100', b: 2, c: 3) }

    let(:fake_logger) { instance_double(Logger).as_null_object }
    let(:expected_metric_string) { 'sample#memory=100 tag#b=2 tag#c=3' }

    before do
      allow(described_class).to receive(:logger).and_return(fake_logger)
    end

    it 'logs the metric' do
      record_metric

      expect(fake_logger).to have_received(:info).with(expected_metric_string)
    end
  end

  describe '.tag_string' do
    subject { described_class.tag_string(tags) }

    let(:fake_logger) { instance_double(Logger).as_null_object }
    let(:tags) { { d: 4, e: 5 } }

    before do
      allow(described_class).to receive(:logger).and_return(fake_logger)
    end

    context 'when global tags missing' do
      before do
        Traxor::Tags.controller = nil
        Traxor::Tags.sidekiq = nil
      end

      it { is_expected.to eq('tag#d=4 tag#e=5') }
    end

    context 'when global tags present' do
      around do |example|
        Traxor::Tags.controller = { controller: 1 }
        Traxor::Tags.sidekiq = { sidekiq: 2 }

        example.run

        Traxor::Tags.controller = nil
        Traxor::Tags.sidekiq = nil
      end

      it { is_expected.to include('tag#controller=1') }
      it { is_expected.to include('tag#sidekiq=2') }
    end
  end

  describe '.normalize_values' do
    module ParentModule
      module ChildModule; end
    end

    subject { described_class.normalize_values(value) }

    let(:value) { ParentModule::ChildModule }
    let(:normalized) { 'parent_module.child_module' }

    it { is_expected.to eq(normalized) }
  end

  describe '.log' do
    let(:unformatted) { 'THE::TestThis.a_b' }
    let(:formatted) { 'the.test_this.a_b' }
    let(:fake_logger) { instance_double(Logger).as_null_object }

    before do
      allow(described_class).to receive(:logger).and_return(fake_logger)
    end

    it 'logs an info string normalized' do
      described_class.log(unformatted)

      expect(fake_logger).to have_received(:info).with(formatted)
    end
  end
end
