# frozen_string_literal: true

require 'traxor/rack/middleware/pre'

RSpec.describe Traxor::Rack::Middleware::Pre do
  class FakeApp
    def call(env)
      sleep 0.2
    end
  end

  let(:middleware) { described_class.new(app) }
  let(:app) { FakeApp.new }
  let(:env) { { Traxor::Rack::Middleware::QueueTime::X_REQUEST_START => 10.minutes.ago.to_f } }
  let(:fake_gc_duration) { 4.seconds.to_i }

  before do
    allow(Traxor::Metric).to receive(:measure)
    allow(Traxor::Metric).to receive(:count)
    allow(GC::Profiler).to receive(:total_time).and_return(fake_gc_duration)
  end

  it 'sets the time the request is started' do
    Thread.new do
      expect { middleware.call(env) }.to(change { Traxor::Rack::Middleware.request_start_at })
    end.join
  end

  it 'sets the time before the request' do
    Thread.new do
      expect { middleware.call(env) }.to(change { Traxor::Rack::Middleware.pre_start_at })
    end.join
  end

  it 'sets the gc stats before the request' do
    Thread.new do
      expect { middleware.call(env) }.to(change { Traxor::Rack::Middleware.gc_stat_before })
    end.join
  end

  it 'sets the time after the request' do
    Thread.new do
      expect { middleware.call(env) }.to(change { Traxor::Rack::Middleware.post_finish_at })
    end.join
  end

  it 'sets the gc stats after the request' do
    Thread.new do
      expect { middleware.call(env) }.to(change { Traxor::Rack::Middleware.gc_stat_after })
    end.join
  end

  it 'records the gc duration' do
    Thread.new do
      expect(Traxor::Metric).to(
        receive(:measure).with(
          Traxor::Rack::Middleware::Pre::GC_DURATION_METRIC,
          "#{(fake_gc_duration * 1_000).to_f.round(2)}ms"
        )
      )

      middleware.call(env)
    end.join
  end

  it 'records the request metrics' do
    Thread.new do
      expect(Traxor::Metric).to(
        receive(:measure).with(Traxor::Rack::Middleware::Pre::MIDDLEWARE_METRIC, any_args)
      )
      expect(Traxor::Metric).to(
        receive(:measure).with(Traxor::Rack::Middleware::Pre::DURATION_METRIC, any_args)
      )
      expect(Traxor::Metric).to(
        receive(:measure).with(Traxor::Rack::Middleware::Pre::QUEUE_METRIC, any_args)
      )
      expect(Traxor::Metric).to(
        receive(:count).with(Traxor::Rack::Middleware::Pre::REQUEST_COUNT_METRIC, any_args)
      )

      Traxor::Rack::Middleware.pre_finish_at = Time.now.utc
      Traxor::Rack::Middleware.post_start_at = Time.now.utc

      middleware.call(env)
    end.join
  end

  it 'records the gc metrics' do
    Thread.new do
      expect(Traxor::Metric).to(
        receive(:measure).with(Traxor::Rack::Middleware::Pre::GC_DURATION_METRIC, any_args)
      )
      expect(Traxor::Metric).to(
        receive(:count).with(Traxor::Rack::Middleware::Pre::GC_COUNT_METRIC, any_args)
      )
      expect(Traxor::Metric).to(
        receive(:count).with(Traxor::Rack::Middleware::Pre::MAJOR_METRIC, any_args)
      )
      expect(Traxor::Metric).to(
        receive(:count).with(Traxor::Rack::Middleware::Pre::MINOR_METRIC, any_args)
      )
      expect(Traxor::Metric).to(
        receive(:count).with(Traxor::Rack::Middleware::Pre::ALLOCATED_METRIC, any_args)
      )

      middleware.call(env)
    end.join
  end
end
