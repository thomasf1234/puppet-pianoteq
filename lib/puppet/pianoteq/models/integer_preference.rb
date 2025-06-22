require 'rexml/document'
require 'puppet/pianoteq/models/value_preference'

module Pianoteq
  module Models
    class IntegerPreference < ValuePreference
      def self.from_element(element)
        preference = new(element['name'])

        val = element['val']
        preference.value = val.to_i if !val.nil?

        preference
      end

      def validate
        errors = {}

        errors[:name] = "name must be a string" if !@name.kind_of?(String)
        errors[:value] = "value must be a integer" if !@value.kind_of?(Integer)

        errors
      end

      def to_element
        element = REXML::Element.new('VALUE')
        element.add_attributes({'name' => @name, 'val' => @value.to_s})
        element
      end
    end
  end
end
