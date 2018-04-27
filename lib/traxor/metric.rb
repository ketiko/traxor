require 'active_support/inflector/inflections'

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
      Traxor::Tags.all.merge(tags).map do |tag_name, tag_value|
        "tag##{tag_name}=#{tag_value}"
      end.join(' '.freeze)
    end

    def self.normalize_values(value)
      value.to_s.gsub(/::/, '.'.freeze).underscore.strip
    end

    def self.log(string)
      Traxor.logger.info(normalize_values(string))
    end
  end
end
