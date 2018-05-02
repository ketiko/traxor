# frozen_string_literal: true

require 'traxor/faraday'

RSpec.describe Traxor::Faraday do
  describe '.record' do
    let(:now) { Time.now.utc }
    let(:event) do
      ActiveSupport::Notifications::Event.new(
        nil,
        now,
        now + 0.05,
        nil,
        url: URI.parse('http://www.google.com/testing'),
        method: :GET
      )
    end
    let(:tags) { { faraday_host: 'www.google.com', faraday_method: :GET } }

    it 'records the metrics' do
      expect(Traxor::Metric).to(
        receive(:count).with(Traxor::Faraday::COUNT_METRIC, 1, tags)
      )
      expect(Traxor::Metric).to(
        receive(:measure).with(Traxor::Faraday::DURATION_METRIC, '50.0ms', tags)
      )

      described_class.record(event)
    end
  end

  describe 'subscription' do
    it 'calls record' do
      expect(described_class).to receive(:record)

      ActiveSupport::Notifications.instrument('request.faraday')
    end
  end
end
