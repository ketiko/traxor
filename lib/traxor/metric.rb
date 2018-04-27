module Traxor
  module Metric
    def self.count(name, value, tags = {})
      logger.info("count##{name}=#{value} #{tag_string(tags)}".strip)
    end

    def self.measure(name, value, tags = {})
      logger.info("measure##{name}=#{value} #{tag_string(tags)}".strip)
    end

    def self.sample(name, value, tags = {})
      logger.info("sample##{name}=#{value} #{tag_string(tags)}".strip)
    end

    def self.tag_string(tags)
      Traxor.current_tags.merge(tags).map do |tag_name, tag_value|
        "tag##{tag_name}=#{tag_value}"
      end.join(' ')
    end

    def self.logger
      @logger ||= Traxor.config.logger
    end
  end
end
