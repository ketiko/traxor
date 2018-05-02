require 'active_support/core_ext/string/inflections'

module Traxor
  module Metric
    def self.count(name, value, tags = {})
      log("count##{name}=#{value} #{tag_string(tags)}")
    end

    def self.measure(name, value, tags = {})
      log("measure##{name}=#{value} #{tag_string(tags)}")
    end

    def self.sample(name, value, tags = {})
      log("sample##{name}=#{value} #{tag_string(tags)}")
    end

    def self.tag_string(tags)
      Hash(tags).merge(Traxor::Tags.all).map do |tag_name, tag_value|
        "tag##{tag_name}=#{tag_value}"
      end.join(' '.freeze)
    end

    def self.normalize_values(value)
      value.to_s.gsub(/::/, '.'.freeze).underscore.strip
    end

    def self.log(string)
      logger.info(normalize_values(string))
    end

    def self.logger
      Traxor.logger
    end
  end
end
