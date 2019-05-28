# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

module Traxor
  module Metric
    class Line
      def self.record
        line = new
        yield line
        line.flush
      end

      def initialize
        @counts = []
        @measures = []
        @samples = []
        @tags = {}
      end

      def count(name, value, tags = {})
        @counts << [name, value]
        @tags.merge!(tags)
      end

      def measure(name, value, tags = {})
        @measures << [name, value]
        @tags.merge!(tags)
      end

      def sample(name, value, tags = {})
        @samples << [name, value]
        @tags.merge!(tags)
      end

      def flush
        line = ''

        @counts.each { |name, value| line += " count##{name}=#{value}" }
        @measures.each { |name, value| line += " measure##{name}=#{value}" }
        @samples.each { |name, value| line += " sample##{name}=#{value}" }

        log("#{line} #{tag_string(@tags)}")
      end

      def tag_string(tags)
        Hash(tags).merge(Traxor::Tags.all).map do |tag_name, tag_value|
          "tag##{tag_name}=#{tag_value}"
        end.join(' ')
      end

      def normalize_values(value)
        value.to_s.gsub(/::/, '.').underscore.strip
      end

      def log(string)
        return unless Traxor.enabled?

        logger.info(normalize_values(string))
      end

      def logger
        Traxor.logger
      end
    end
  end
end
