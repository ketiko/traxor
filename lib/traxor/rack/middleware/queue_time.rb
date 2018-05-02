module Traxor
  module Rack
    module Middleware
      module QueueTime
        X_REQUEST_START = 'HTTP_X_REQUEST_START'.freeze

        # any timestamps before this are thrown out and the parser
        # will try again with a larger unit (2000/1/1 UTC)
        EARLIEST_ACCEPTABLE_TIME = Time.at(946_684_800).utc

        DIVISORS = [1_000_000, 1_000, 1].freeze

        def self.parse(env)
          return unless env[X_REQUEST_START]

          value = env[X_REQUEST_START].to_s.sub(/t=/, ''.freeze)
          DIVISORS.each do |divisor|
            time = Time.at(value.to_f / divisor).utc
            return time if time > EARLIEST_ACCEPTABLE_TIME
          end

          nil
        end
      end
    end
  end
end
