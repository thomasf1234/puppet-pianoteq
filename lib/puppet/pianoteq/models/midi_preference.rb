require 'rexml/document'
require 'puppet/pianoteq/models/preference'

module Pianoteq
  module Models
    class MidiPreference < Preference
      attr_accessor :listen_all, :devices

      def initialize(name, devices=[])
        super(name)
        @devices = devices
      end

      def self.from_element(element)
        preference = new(element['name'])

        midi_setup_element = element.elements['midi-setup']
        preference.listen_all = midi_setup_element.attributes['listen-all'] == '1' ? true : false
        midi_setup_element.elements.each('device') do |device_element|
          device = {}
          device['name'] = device_element.attributes['name']
          device['client_port'] = device_element.attributes['id'].split('-').first.to_i
          preference.devices << device.compact
        end
        
        preference
      end
      
      def validate
        errors = {}

        errors[:listen_all] = "listen_all must be a boolean" unless [true, false].include?(@listen_all)
        
        if !@devices.nil?
          errors[:devices] = "devices must be a list of device hashes" and return errors unless @devices.kind_of?(Array)

          @devices.each do |device|
            errors[:devices] = "invalid device format #{device}" and return errors unless device.kind_of?(Hash) 
            errors[:devices] = "device must contain a valid client_port" and return errors unless device['client_port'].kind_of?(Integer) && device['client_port'] >= 0

            name = device['name']

            if !name.nil?
              errors[:devices] = "device must contain a valid name" and return errors unless name.kind_of?(String) && !name.empty?
            end
          end
        end

        errors
      end

      def to_element
        element = REXML::Element.new('VALUE')
        element.add_attributes({'name' => 'midi-setup'})
        midi_setup_element = REXML::Element.new('midi-setup')
        listen_all_value = @listen_all ? '1' : '0'
        midi_setup_element.add_attributes({'listen-all' => listen_all_value})
        
        devices.each do |device|
          device_element = REXML::Element.new('device')
          id = "#{device['client_port']}-0"
          device_element.add_attributes({'id' => id})
          device_element.add_attributes({'name' => device['name']}) if device.has_key?('name')
          midi_setup_element.add(device_element)
        end

        element.add(midi_setup_element)
        element
      end
    end
  end
end
