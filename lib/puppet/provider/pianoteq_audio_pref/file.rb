require 'rexml/document'
require 'puppet/pianoteq/repositories/preference_repository'
require 'puppet/pianoteq/models/audio_preference'

Puppet::Type.type(:pianoteq_audio_pref).provide(:file) do 
  desc 'Manage Pianoteq audio preferences in the .prefs file'

  # convience getter/setter to pull properties from @property_hash
  mk_resource_methods

  # loads all resources on the system and populates @property_hash for our resource with the current state
  def self.instances
    preference_repository = Pianoteq::Repositories::PreferenceRepository.new
    audio_preference = preference_repository.find('audio-setup')

    return [] if audio_preference.nil?

    instances = []

    attributes_hash = { 
      ensure: :present, 
      name: 'audio-setup',
      device_name: audio_preference.device_name,
      device_type: audio_preference.device_type, 
      sample_rate: audio_preference.sample_rate,
      buffer_size: audio_preference.buffer_size
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
    @property_hash[:device_name] = resource[:device_name]
    @property_hash[:device_type] = resource[:device_type]
    @property_hash[:sample_rate] = resource[:sample_rate]
    @property_hash[:buffer_size] = resource[:buffer_size]
  end

  def destroy
    @property_hash[:ensure] = :absent
  end

  # Flush is only called when the resource is not in sync
  def flush
    preference_repository = Pianoteq::Repositories::PreferenceRepository.new

    if @property_hash[:ensure] == :present
      preference = Pianoteq::Models::AudioPreference.new('audio-setup')
      preference.device_name = @property_hash[:device_name]
      preference.device_type = @property_hash[:device_type]
      preference.sample_rate = @property_hash[:sample_rate]
      preference.buffer_size = @property_hash[:buffer_size]
      preference.force_stereo = false # This is always 0 but couldn't find a way to configure
      preference_repository.save(preference)
    end

    if @property_hash[:ensure] == :absent
      preference_repository.delete('audio-setup')
    end
  end
end
