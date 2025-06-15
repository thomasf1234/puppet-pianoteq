require 'puppet/pianoteq/models/preference'

module Pianoteq
  module Models
    class ValuePreference < Preference
      attr_accessor :value

      def initialize(name, value=nil)
        super(name)
        @value = value
      end
    end
  end
end

