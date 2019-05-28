# frozen_string_literal: true

require 'traxor/rails/action_controller'

RSpec.describe Traxor::Rails::ActionController do
  describe '.add_controller_tags' do
    let(:event) do
      ActiveSupport::Notifications::Event.new(
        nil,
        nil,
        nil,
        nil,
        controller: 'MyController',
        action: 'index',
        method: 'GET'
      )
    end
    let(:tags) do
      {
        controller_name: 'MyController',
        controller_action: 'index',
        controller_method: 'GET'
      }
    end

    it 'sets global controller tags' do
      Thread.new do
        described_class.add_controller_tags(event)

        expect(Traxor::Tags.controller).to eq(tags)
      end.join
    end
  end

  describe '.record' do
    let(:now) { Time.now.utc }
    let(:event) do
      ActiveSupport::Notifications::Event.new(
        'name',
        now,
        now + 1,
        nil,
        db_runtime: 30,
        view_runtime: 25,
        exception: StandardError.new
      )
    end
    let(:tags) { { faraday_host: 'www.google.com', faraday_method: :GET } }

    it 'records the metrics' do
      expect_any_instance_of(Traxor::Metric::Line).to(
        receive(:count).with(Traxor::Rails::ActionController::COUNT_METRIC, 1)
      )
      expect_any_instance_of(Traxor::Metric::Line).to(
        receive(:measure).with(Traxor::Rails::ActionController::TOTAL_METRIC, '1000.0ms')
      )
      expect_any_instance_of(Traxor::Metric::Line).to(
        receive(:measure).with(Traxor::Rails::ActionController::RUBY_METRIC, '945.0ms')
      )
      expect_any_instance_of(Traxor::Metric::Line).to(
        receive(:measure).with(Traxor::Rails::ActionController::DB_METRIC, '30.0ms')
      )
      expect_any_instance_of(Traxor::Metric::Line).to(
        receive(:measure).with(Traxor::Rails::ActionController::VIEW_METRIC, '25.0ms')
      )
      expect_any_instance_of(Traxor::Metric::Line).to(
        receive(:count).with(Traxor::Rails::ActionController::EXCEPTION_METRIC, 1)
      )

      described_class.record(event)
    end
  end

  describe 'subscriptions' do
    it 'calls add_controller_tags' do
      expect(described_class).to receive(:add_controller_tags)

      ActiveSupport::Notifications.instrument('start_processing.action_controller')
    end

    it 'calls record' do
      expect(described_class).to receive(:record)

      ActiveSupport::Notifications.instrument('process_action.action_controller')
    end
  end
end
