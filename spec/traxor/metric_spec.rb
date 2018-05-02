RSpec.describe Traxor::Metric do
  describe '.count' do
    subject { described_class.count('name', 'value') }

    let(:expected_metric_string) do
      'count#name=value '
    end

    it 'logs the metric' do
      expect(described_class).to receive(:log).with(expected_metric_string)

      subject
    end
  end

  describe '.measure' do
    subject { described_class.measure('name', 'value', a: 1) }

    let(:expected_metric_string) do
      'measure#name=value tag#a=1'
    end

    it 'logs the metric' do
      expect(described_class).to receive(:log).with(expected_metric_string)

      subject
    end
  end

  describe '.sample' do
    subject { described_class.sample('name', 'value', a: 1, b: 2) }

    let(:expected_metric_string) do
      'sample#name=value tag#a=1 tag#b=2'
    end

    it 'logs the metric' do
      expect(described_class).to receive(:log).with(expected_metric_string)

      subject
    end
  end

  describe '.tag_string' do
    subject { described_class.tag_string(tags) }

    let(:tags) { { a: 3, b: 4 } }

    context 'when global tags missing' do
      before do
        Traxor::Tags.controller = nil
        Traxor::Tags.sidekiq = nil
      end

      it { is_expected.to eq('tag#a=3 tag#b=4') }
    end

    context 'when global tags present' do
      before do
        Traxor::Tags.controller = { controller: 1 }
        Traxor::Tags.sidekiq = { sidekiq: 2 }
      end

      after do
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

    it 'logs an info string normalized' do
      expect(Traxor.logger).to receive(:info).with(formatted)

      described_class.log(unformatted)
    end
  end
end
