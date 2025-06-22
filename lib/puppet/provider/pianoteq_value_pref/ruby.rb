require 'rexml/document'
require 'puppet/pianoteq/repositories/preference_repository'
require 'puppet/pianoteq/models/value_preference'

#http://garylarizza.com/blog/2013/12/15/seriously-what-is-this-provider-doing/

Puppet::Type.type(:pianoteq_value_pref).provide(:ruby) do 
  desc 'Manage Pianoteq value preferences in the .prefs file'

  #confine feature :rexml 

  # convience getter/setter to pull properties from @property_hash
  mk_resource_methods

  # loads all resources on the system and populates @property_hash for our resource with the current state
  def self.instances
    instances = []

    preference_repository = Pianoteq::Repositories::PreferenceRepository.new
    preferences = preference_repository.all.select { |preference| preference.kind_of?(Pianoteq::Models::ValuePreference) }

    preferences.each do |preference|
      # puppet doesn't support true and false as safe_insync? assumes a value of false is in sync. 
      value = [true, false].include?(preference.value) ? preference.value.to_s.to_sym : preference.value
      attributes_hash = { ensure: :present, value: value, name: preference.name }
      instances << new(attributes_hash) 
    end
    
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
    @property_hash[:value] = resource[:value]
  end

  def destroy
    @property_hash[:ensure] = :absent
  end

  # Flush is only called when the resource is not in sync
  def flush
    preference_repository = Pianoteq::Repositories::PreferenceRepository.new

    if @property_hash[:ensure] == :present
      preference_klass = preference_repository.type_mappings[@property_hash[:name]]

      # puppet doesn't support true and false as safe_insync? assumes a value of false is in sync. 
      value = [:true, :false].include?(@property_hash[:value]) ? @property_hash[:value] == :true : @property_hash[:value]
      preference = preference_klass.new(@property_hash[:name], value)

      preference_repository.save(preference)
    end

    if @property_hash[:ensure] == :absent
      preference_repository.delete(@property_hash[:name])
    end
  end
end