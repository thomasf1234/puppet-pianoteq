require 'rexml/document'
require 'puppet/pianoteq/models/value_preference'

module Pianoteq
  module Models
    class MulticorePreference < ValuePreference
      def self.from_element(element)
        preference = new(element['name'])
        val = element['val']
        preference.value = case val
        when '2'
            'max'
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

        errors[:name] = "name must be multicore" if @name != 'multicore'
        errors[:value] = "value must be a boolean or max" if ![:max, 'max', true, false].include?(@value)

        errors
      end

      def to_element
        element = REXML::Element.new('VALUE')
        val = case @value 
        when 'max' 
          '2'
        when true
          '1'
        when false
          '0'
        end

        element.add_attributes({'name' => @name, 'val' => val})
        element
      end
    end
  end
end
