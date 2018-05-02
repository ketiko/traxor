RSpec.describe Traxor::Tags do
  it { is_expected.to have_attributes(controller: nil, sidekiq: nil) }

  describe '.all' do
    subject { described_class.all }

    before do
      described_class.controller = controller_tags
      described_class.sidekiq = sidekiq_tags
    end

    context 'when controller tags nil' do
      let(:controller_tags) { nil }
      let(:sidekiq_tags) { { b: 2 } }

      it { is_expected.to eq(sidekiq_tags) }
    end

    context 'when sidekiq tags empty' do
      let(:controller_tags) { { a: 1 } }
      let(:sidekiq_tags) { nil }

      it { is_expected.to eq(controller_tags) }
    end

    context 'when controller tags and sidekiq tags empty' do
      let(:controller_tags) { nil }
      let(:sidekiq_tags) { nil }

      it { is_expected.to eq({}) }
    end

    context 'when controller tags and sidekiq tags present' do
      let(:controller_tags) { { a: 1 } }
      let(:sidekiq_tags) { { b: 2 } }

      it { is_expected.to eq(controller_tags.merge(sidekiq_tags)) }
    end
  end
end
