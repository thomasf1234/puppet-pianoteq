require 'rexml/document'
require 'puppet/pianoteq/models/value_preference'

module Pianoteq
  module Models
    class StringPreference < ValuePreference
      def self.from_element(element)
        preference = new(element['name'], element['val'])
        preference.value = element['val']

        preference
      end

      def validate
        errors = {}

        errors[:name] = "name must be a string" if !@name.kind_of?(String)
        errors[:value] = "value must be a string" if !@name.kind_of?(String)

        errors
      end

      def to_element
        element = REXML::Element.new('VALUE')
        element.add_attributes({'name' => @name, 'val' => @value})
        element
      end
    end
  end
end
