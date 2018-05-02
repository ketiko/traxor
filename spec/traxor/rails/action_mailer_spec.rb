# frozen_string_literal: true

require 'traxor/rails/action_mailer'

RSpec.describe Traxor::Rails::ActionMailer do
  describe '.record' do
    let(:now) { Time.now.utc }
    let(:event) do
      ActiveSupport::Notifications::Event.new(
        nil,
        nil,
        nil,
        nil,
        mailer: 'MyMailer'
      )
    end
    let(:tags) { { action_mailer_class_name: 'MyMailer' } }

    it 'records the metrics' do
      expect(Traxor::Metric).to receive(:count).with(Traxor::Rails::ActionMailer::COUNT_METRIC, 1, tags)

      described_class.record(event)
    end
  end
end
