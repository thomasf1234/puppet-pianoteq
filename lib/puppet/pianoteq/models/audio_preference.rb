require 'rexml/document'
require 'puppet/pianoteq/models/preference'

module Pianoteq
  module Models
    class AudioPreference < Preference
      attr_accessor :device_name, :device_type, :sample_rate, :buffer_size, :force_stereo

      def self.from_element(element)
        preference = new(element['name'])

        device_setup_element = element.elements['DEVICESETUP']
        preference.device_name = device_setup_element.attributes['audioOutputDeviceName']
        preference.device_type = device_setup_element.attributes['deviceType']

        if device_setup_element.attributes['audioDeviceRate']
          preference.sample_rate = device_setup_element.attributes['audioDeviceRate'].to_i
        end
        
        if device_setup_element.attributes['audioDeviceBufferSize']
          preference.buffer_size = device_setup_element.attributes['audioDeviceBufferSize'].to_i
        end

        preference.force_stereo = device_setup_element.attributes['forceStereo'] == '1' ? true : false
        
        preference
      end
      
      def validate
        errors = {}

        errors[:device_name] = "device_name must be a string" if !@device_name.kind_of?(String)
        errors[:device_type] = "device_type must be a string" if !@device_type.kind_of?(String)
        errors[:sample_rate] = "sample_rate must be an integer" if !@sample_rate.kind_of?(Integer)
        errors[:buffer_size] = "buffer_size must be an integer" if !@buffer_size.kind_of?(Integer)
        errors[:force_stereo] = "force_stereo must be a boolean" if ![true, false].include?(@force_stereo)
        
        errors
      end

      def to_element
        element = REXML::Element.new('VALUE')
        element.add_attributes({'name' => 'audio-setup'})
        device_setup_element = REXML::Element.new('DEVICESETUP')
        device_setup_element.add_attributes({'deviceType' => @device_type})
        device_setup_element.add_attributes({'audioOutputDeviceName' => @device_name})
        device_setup_element.add_attributes({'audioDeviceRate' => @sample_rate}) if !@sample_rate.nil?
        device_setup_element.add_attributes({'audioDeviceBufferSize' => @buffer_size}) if !@buffer_size.nil?
        
        if !@force_stereo.nil?
          _force_stereo = @force_stereo ? '1' : '0'
          device_setup_element.add_attributes({'forceStereo' => _force_stereo})
        end

        element.add(device_setup_element)
        element
      end
    end
  end
end
