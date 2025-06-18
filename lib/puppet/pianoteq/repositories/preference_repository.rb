require 'rexml/document'

require 'puppet/pianoteq/models/preference'
require 'puppet/pianoteq/models/value_preference'
require 'puppet/pianoteq/models/multicore_preference'
require 'puppet/pianoteq/models/boolean_preference'
require 'puppet/pianoteq/models/integer_preference'
require 'puppet/pianoteq/models/string_preference'
require 'puppet/pianoteq/models/midi_preference'
require 'puppet/pianoteq/models/audio_preference'

module Pianoteq
  module Repositories
    class PreferenceRepository  
      PATH = '/etc/opt/pianoteq/8.4.1/pianoteq.prefs'

      def all
        preferences = []
        return preferences if !File.exist?(PATH) 

        xml = File.read(PATH)
        document = REXML::Document.new(xml)

        document.elements.each('PROPERTIES/VALUE') do |element|
          preference_name = element['name']

          preference_klass = type_mappings[preference_name]

          if !preference_klass.nil?
            preference = preference_klass.from_element(element) 
            preferences << preference
          end
        end

        preferences
      end

      def find(preference_name)
        raise ArgumentError.new("preference #{preference_name} not supported") if !type_mappings.keys.include?(preference_name)

        return nil if !File.exist?(PATH) 

        xml = File.read(PATH)
        document = REXML::Document.new(xml)

        element = document.elements["PROPERTIES/VALUE[@name='#{preference_name}']"] 

        return nil if element.nil?

        preference_klass = type_mappings[preference_name]
        preference = preference_klass.from_element(element) 

        preference
      end

      def save(preference)
        # validate
        raise ArgumentError.new("preference #{preference.name} not supported") if !type_mappings.keys.include?(preference.name)
        validation_errors = preference.validate
        raise ArgumentError.new("preference #{preference.name} not valid :: #{validation_errors}") if !validation_errors.empty?

        document = find_or_create_document

        # add or replace the preference
        value_element = document.elements["PROPERTIES/VALUE[@name='#{preference.name}']"]
        if value_element.nil?
          properties_element = document.elements["PROPERTIES"]
          properties_element.add(preference.to_element)
        else
          value_element.replace_with(preference.to_element)
        end

        save_document(document)
      end

      def delete(preference_name)
        document = find_or_create_document
        element = document.elements["//PROPERTIES/VALUE[@name='#{preference_name}']"]
        element.parent.delete(element)
        save_document(document)
      end

      def type_mappings
        {
            'multicore' => Models::MulticorePreference,
            'welcome-done' => Models::BooleanPreference,
            'midiArchiveEnabled' => Models::BooleanPreference,
            'midi-setup' => Models::MidiPreference,
            'audio-setup' => Models::AudioPreference,
            'voices' => Models::IntegerPreference,
            'voices_thresh' => Models::IntegerPreference,
            'engine_rate' => Models::IntegerPreference,
            'cpu_overload_detection' => Models::BooleanPreference,
            'user_root_folder' => Models::StringPreference,
            'force_touchscreen_mode' => Models::BooleanPreference,
            'serial' => Models::StringPreference,
            'plcheck' => Models::BooleanPreference,
            'hwname' => Models::StringPreference,
            'LKey' => Models::StringPreference
        }
      end

      private 
      def find_or_create_document
        document = nil

        # load document or build new
        if File.exist?(PATH)
          xml = File.read(PATH)
          document = REXML::Document.new(xml)
        end

        if document.nil? || document.elements['PROPERTIES'].nil?
          document = REXML::Document.new
          xml_decl = REXML::XMLDecl.new('1.0', 'UTF-8')
          document.add(xml_decl)
          properties_element = REXML::Element.new('PROPERTIES')
          document.add(properties_element)
          save_document(document)
        end

        document
      end

      def save_document(document)
        # convert document to formatted xml
        xml = ''
        document.write(:output => xml, :indent => 2)
        xml

        # save xml
        File.write(PATH, xml)
      end
    end
  end
end
