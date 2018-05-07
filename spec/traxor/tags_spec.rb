# frozen_string_literal: true

RSpec.describe Traxor::Tags do
  it { is_expected.to have_attributes(controller: nil, sidekiq: nil) }

  describe '.all' do
    subject { described_class.all }

    context 'when controller tags nil' do
      let(:controller_tags) { nil }
      let(:sidekiq_tags) { { b: 2 } }

      it 'only shows sidekiq tags' do
        Thread.new do
          described_class.controller = controller_tags
          described_class.sidekiq = sidekiq_tags

          is_expected.to eq(sidekiq_tags)
        end.join
      end
    end

    context 'when sidekiq tags empty' do
      let(:controller_tags) { { a: 1 } }
      let(:sidekiq_tags) { nil }

      it 'only shows controller tags' do
        Thread.new do
          described_class.controller = controller_tags
          described_class.sidekiq = sidekiq_tags

          is_expected.to eq(controller_tags)
        end.join
      end
    end

    context 'when controller tags and sidekiq tags empty' do
      let(:controller_tags) { nil }
      let(:sidekiq_tags) { nil }

      it 'only shows no tags' do
        Thread.new do
          described_class.controller = controller_tags
          described_class.sidekiq = sidekiq_tags

          is_expected.to eq({})
        end.join
      end
    end

    context 'when controller tags and sidekiq tags present' do
      let(:controller_tags) { { a: 1 } }
      let(:sidekiq_tags) { { b: 2 } }

      it 'shows both controller and sidekiq tags' do
        Thread.new do
          described_class.controller = controller_tags
          described_class.sidekiq = sidekiq_tags

          is_expected.to eq(controller_tags.merge(sidekiq_tags))
        end.join
      end
    end
  end
end
