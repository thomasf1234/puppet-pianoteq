Puppet::Type.newtype(:pianoteq_midi_pref) do
  @doc = 'Manage Pianoteq MIDI setup'

  ensurable do 
    newvalue(:present) do 
      provider.create unless provider.exists?
    end

    defaultto :present
  end

  newparam(:name, namevar: true) do 
    desc 'The resource name'

    validate do |value|
      raise ArgumentError, "name must be 'midi-setup'" unless value == 'midi-setup'
    end
  end

  newproperty(:listen_all) do 
    desc 'Whether to listen to all MIDI devices'
    newvalue(:true)
    newvalue(:false)
  end

   newproperty(:devices, :array_matching => :all) do 
    desc 'MIDI devices to listen to'

    validate do |device|
      raise ArgumentError, "client_port must be set" if device['client_port'].nil?
      raise ArgumentError, "client_port must be a valid MIDI port'" unless device['client_port'] >= 0
      raise ArgumentError, "name must be a string" if !device['name'].nil? && !device['name'].kind_of?(String)
    end

    def insync?(is)
      is == should
    end
  end

  autorequire(:package) do
    ['pianoteq']
  end
end