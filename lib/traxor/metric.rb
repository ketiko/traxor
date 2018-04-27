module Traxor
  module Metric
    def self.count(name, value, tags = {})
      Traxor.logger.info(normalize_name("count##{name}=#{value} #{tag_string(tags)}"))
    end

    def self.measure(name, value, tags = {})
      Traxor.logger.info(normalize_name("measure##{name}=#{value} #{tag_string(tags)}"))
    end

    def self.sample(name, value, tags = {})
      Traxor.logger.info(normalize_name("sample##{name}=#{value} #{tag_string(tags)}"))
    end

    def self.tag_string(tags)
      Traxor::Tags.all.merge(tags).map do |tag_name, tag_value|
        "tag##{tag_name}=#{tag_value}"
      end.join(' '.freeze)
    end

    def self.normalize_name(value)
      value.to_s.gsub(/::/, '.'.freeze).underscore.strip
    end
  end
end
