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
    subject { described_class.time_before }

    context 'when pre_start_at is missing' do
      it 'returns 0' do
        Thread.new do
          described_class.pre_start_at = nil
          is_expected.to eq(0)
        end.join
      end
    end

    context 'when pre_start_at is present' do
      it 'returns the delta' do
        Thread.new do
          current = Time.now.utc
          described_class.pre_start_at = current - 10.minutes
          described_class.pre_finish_at = current - 5.minutes

          is_expected.to eq(5.minutes.to_f)
          is_expected.to be_a Float
        end.join
      end
    end
  end

  describe '.time_after' do
    subject { described_class.time_after }

    context 'when post_start_at is missing' do
      it 'returns 0' do
        Thread.new do
          described_class.post_start_at = nil
          is_expected.to eq(0)
        end.join
      end
    end

    context 'when post_start_at is present' do
      it 'returns the delta' do
        Thread.new do
          current = Time.now.utc
          described_class.post_start_at = current - 10.minutes
          described_class.post_finish_at = current - 5.minutes

          is_expected.to eq(5.minutes.to_f)
          is_expected.to be_a Float
        end.join
      end
    end
  end

  describe '.middleware_total' do
    subject { described_class.middleware_total }

    it 'returns pre and post middleware durations in ms' do
      Thread.new do
        current = Time.now.utc
        described_class.pre_start_at = current - 10.minutes
        described_class.pre_finish_at = current - 5.minutes
        described_class.post_start_at = current - 7.minutes
        described_class.post_finish_at = current - 3.minutes

        is_expected.to eq(9.minutes.to_f * 1_000)
        is_expected.to be_a Float
      end.join
    end
  end

  describe '.request_total' do
    subject { described_class.request_total }

    context 'when pre_start_at is missing' do
      it 'returns 0' do
        Thread.new do
          described_class.pre_start_at = nil
          is_expected.to eq(0)
        end.join
      end
    end

    context 'when pre_start_at is present' do
      it 'returns the delta in ms' do
        Thread.new do
          current = Time.now.utc
          described_class.pre_start_at = current - 10.minutes
          described_class.post_finish_at = current - 5.minutes

          is_expected.to eq(5.minutes.to_f * 1_000)
          is_expected.to be_a Float
        end.join
      end
    end
  end

  describe '.request_queue_total' do
    subject { described_class.request_queue_total }

    context 'when request_start_at is missing' do
      it 'returns 0' do
        Thread.new do
          described_class.request_start_at = nil
          is_expected.to eq(0)
        end.join
      end
    end

    context 'when request_start_at is present' do
      it 'returns the delta in ms' do
        Thread.new do
          current = Time.now.utc
          described_class.request_start_at = current - 10.minutes
          described_class.pre_start_at = current - 5.minutes

          is_expected.to eq(5.minutes.to_f * 1_000)
          is_expected.to be_a Float
        end.join
      end
    end
  end

  describe '.gc_count' do
    subject { described_class.gc_count }

    it 'returns the count of gc total runs during the request window' do
      Thread.new do
        described_class.gc_stat_after = { count: 10 }
        described_class.gc_stat_before = { count: 3 }

        is_expected.to eq(7)
      end.join
    end
  end

  describe '.gc_major_count' do
    subject { described_class.gc_major_count }

    it 'returns the count of gc major runs during the request window' do
      Thread.new do
        described_class.gc_stat_after = { major_gc_count: 3 }
        described_class.gc_stat_before = { major_gc_count: 0 }

        is_expected.to eq(3)
      end.join
    end
  end

  describe '.gc_minor_count' do
    subject { described_class.gc_minor_count }

    it 'returns the count of gc minor runs during the request window' do
      Thread.new do
        described_class.gc_stat_after = { minor_gc_count: 3 }
        described_class.gc_stat_before = { minor_gc_count: 1 }

        is_expected.to eq(2)
      end.join
    end
  end

  describe '.gc_allocated_objects_count' do
    subject { described_class.gc_allocated_objects_count }

    it 'returns the count of allocated objects during the request window' do
      Thread.new do
        described_class.gc_stat_after = { total_allocated_objects: 700 }
        described_class.gc_stat_before = { total_allocated_objects: 500 }

        is_expected.to eq(200)
      end.join
    end
  end
end
