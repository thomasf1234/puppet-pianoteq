require 'puppet/pianoteq/models/value_preference'

module Pianoteq
  module Models
    class BooleanPreference < ValuePreference
      def self.from_element(element)
        preference = new(element['name'])

        val = element['val']
        preference.value = case val
        when '1'
            true
        when '0'
            false
        else
            raise ArgumentError.new("val #{val} not supported")
        end
        
        preference
      end

      def validate
        errors = {}

        errors[:name] = "name must be a string" if !@name.kind_of?(String)
        errors[:value] = "value must be a boolean" if ![true, false].include?(@value)

        errors
      end

      def to_element
        element = REXML::Element.new('VALUE')
        val = @value ? '1' : '0'
        element.add_attributes({'name' => @name, 'val' => val})
        element
      end
    end
  end
end
