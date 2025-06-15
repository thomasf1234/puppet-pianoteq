require 'rexml/document'
require 'puppet/pianoteq/repositories/preference_repository'
require 'puppet/pianoteq/models/value_preference'

Puppet::Type.type(:pianoteq_midi_pref).provide(:file) do 
  desc 'Manage Pianoteq MIDI preferences in the .prefs file'

  # convience getter/setter to pull properties from @property_hash
  mk_resource_methods

  # loads all resources on the system and populates @property_hash for our resource with the current state
  def self.instances
    preference_repository = Pianoteq::Repositories::PreferenceRepository.new
    midi_preference = preference_repository.find('midi-setup')

    return [] if midi_preference.nil?

    instances = []

    listen_all = [true, false].include?(midi_preference.listen_all) ? midi_preference.listen_all.to_s.to_sym : midi_preference.listen_all

    attributes_hash = { 
      ensure: :present, 
      name: 'midi-setup',
      listen_all: listen_all,
      devices: midi_preference.devices
    }
    instances << new(attributes_hash) 
    
    instances
  end

  # as instances cover all resources on the system, the resources declared 
  # in the manifest/catalog are passed as an argument here to prefetch the current
  # resource properties. This can easily be done by finding the provider instances
  # for our resources and setting it on each resource
  def self.prefetch(resources)
    instances.each do |instance|
      resource = resources[instance.name]
      resource.provider = instance if !resource.nil?
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  # create must set the property_hash because this did not exist on the system during the instances/prefetch
  def create
    @property_hash[:ensure] = :present
    @property_hash[:name] = resource[:name]
    @property_hash[:listen_all] = resource[:listen_all]
    @property_hash[:devices] = resource[:devices]
  end

  def destroy
    @property_hash[:ensure] = :absent
  end

  # Flush is only called when the resource is not in sync
  def flush
    preference_repository = Pianoteq::Repositories::PreferenceRepository.new

    if @property_hash[:ensure] == :present
      preference = Pianoteq::Models::MidiPreference.new('midi-setup')

      listen_all = [:true, :false].include?(@property_hash[:listen_all]) ? @property_hash[:listen_all] == :true : @property_hash[:listen_all]
      preference.listen_all = listen_all
      preference.devices = @property_hash[:devices]
      preference_repository.save(preference)
    end

    if @property_hash[:ensure] == :absent
      preference_repository.delete('midi-setup')
    end
  end
end