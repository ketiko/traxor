# frozen_string_literal: true

require 'traxor/rack/middleware/post'

RSpec.describe Traxor::Rack::Middleware::Post do
  let(:middleware) { described_class.new(app) }
  let(:app) { instance_double('app', call: nil) }
  let(:env) { instance_double('env') }

  it 'records the time before the request' do
    expect { middleware.call(env) }.to(change { Traxor::Rack::Middleware.pre_finish_at })
  end

  it 'records the time before the request' do
    expect { middleware.call(env) }.to(change { Traxor::Rack::Middleware.post_start_at })
  end

  it 'records them in the correct order' do
    Thread.new do
      middleware.call(env)

      expect(Traxor::Rack::Middleware.pre_finish_at).to be < Traxor::Rack::Middleware.post_start_at
    end.join
  end
end
