require 'puppet/pianoteq/repositories/preference_repository'
require 'puppet/pianoteq/models/preference'

Puppet::Type.newtype(:pianoteq_value_pref) do
  @doc = 'Manage Pianoteq value preferences'

  ensurable

  newparam(:name, namevar: true) do 
    desc 'The preference name'
  end

  newproperty(:value) do 
    desc 'the value to be set for the preference'
    newvalue(:true)
    newvalue(:false)

    validate do |value|            
      name = resource[resource.name_var]

      raise ArgumentError.new("Unsupported value preference #{name}") if ['midi-setup', 'audio-setup'].include?(name)

      preference_repository = Pianoteq::Repositories::PreferenceRepository.new
      preference_klass = preference_repository.type_mappings[name]

      raise ArgumentError.new("Unsupported preference #{name}") if preference_klass.nil?

      preference = preference_klass.new(name, value)
      validation_errors = preference.validate
      raise ArgumentError.new("Invalid value :: #{validation_errors}") unless validation_errors.empty?
    end
  end

  autonotify(:service) do
    ['pianoteq']
  end
end