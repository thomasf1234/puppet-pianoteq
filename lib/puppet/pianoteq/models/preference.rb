module Pianoteq
  module Models
    class Preference
      attr_accessor :name

      def initialize(name)
        @name = name
      end

      def self.from_element(element)
        raise NoMethodError.new("#{self} must implement the method #{__method__}")
      end

      def validate
        raise NoMethodError.new("#{self.class} must implement the method #{__method__}")
      end

      def to_element
        raise NoMethodError.new("#{self.class} must implement the method #{__method__}")
      end
    end
  end
end
