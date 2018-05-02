# frozen_string_literal: true

require 'traxor/rack/middleware/queue_time'

RSpec.describe Traxor::Rack::Middleware::QueueTime do
  describe '.parse' do
    subject { described_class.parse(env) }

    context 'when no header' do
      let(:env) { {} }

      it { is_expected.to be_nil }
    end

    context 'when before 2000/1/1' do
      let(:env) { { 'HTTP_X_REQUEST_START' => "t=#{Time.new(1999, 1, 1).to_f}" } }

      it { is_expected.to be_nil }
    end

    context 'when after 2000/1/1' do
      let(:time) { Time.now.utc }

      Traxor::Rack::Middleware::QueueTime::DIVISORS.each do |divisor|
        context "when multiple of 1 #{divisor}" do
          let(:env) { { 'HTTP_X_REQUEST_START' => "t=#{time.to_f * divisor}" } }

          it { is_expected.to be_within(0.0001).of(time) }
        end
      end
    end
  end
end
