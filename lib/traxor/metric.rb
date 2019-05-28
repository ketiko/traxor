# frozen_string_literal: true

require 'traxor/metric/line'

module Traxor
  module Metric
    def self.count(name, value, tags = {})
      Line.record { |l| l.count(name, value, tags) }
    end

    def self.measure(name, value, tags = {})
      Line.record { |l| l.measure(name, value, tags) }
    end

    def self.sample(name, value, tags = {})
      Line.record { |l| l.sample(name, value, tags) }
    end
  end
end
