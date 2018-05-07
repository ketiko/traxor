# frozen_string_literal: true

require 'traxor/rack/middleware'

RSpec.describe Traxor::Rack::Middleware do
  let(:attributes) do
    {
      pre_start_at: nil,
      pre_finish_at: nil,
      post_start_at: nil,
      post_finish_at: nil,
      request_start_at: nil,
      gc_stat_before: nil,
      gc_stat_after: nil
    }
  end

  it { is_expected.to have_attributes(attributes) }

  describe '.time_before' do
    pending
  end

  describe '.time_after' do
    pending
  end

  describe '.middleware_total' do
    pending
  end

  describe '.request_queue_total' do
    pending
  end

  describe '.gc_count' do
    pending
  end

  describe '.gc_major_count' do
    pending
  end

  describe '.gc_minor_count' do
    pending
  end

  describe '.gc_allocated_objects_count' do
    pending
  end
end
