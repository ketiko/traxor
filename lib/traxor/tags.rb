require 'active_support/core_ext/module/attribute_accessors_per_thread'

module Traxor
  module Tags
    thread_mattr_accessor :controller, :sidekiq

    def self.all
      Hash(controller).merge(Hash(sidekiq))
    end
  end
end
