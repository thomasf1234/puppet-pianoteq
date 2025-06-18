Puppet::Type.newtype(:pianoteq_audio_pref) do
  @doc = 'Manage Pianoteq audio preferences'

  ensurable

  newparam(:name, namevar: true) do 
    desc 'The audio output device name'
    validate do |name|
      raise ArgumentError, 'name must be a audio-setup' unless name == 'audio-setup'
    end
  end

  newproperty(:device_name) do 
    desc 'The audio output device name'
    validate do |device_name|
      raise ArgumentError, 'device_name must be a string' unless device_name.kind_of?(String)
    end
  end

  newproperty(:device_type) do 
    desc 'the device type'
    validate do |device_type|
      raise ArgumentError, 'device_type must be a string' unless device_type.kind_of?(String)
    end
  end

  newproperty(:buffer_size) do 
    desc 'the sample buffer size'
    validate do |buffer_size|
      raise ArgumentError, 'buffer_size must be a positive integer' unless buffer_size.kind_of?(Integer) && buffer_size > 0
    end
  end

  newproperty(:sample_rate) do 
    desc 'the sample rate in Hz'
    validate do |sample_rate|
      raise ArgumentError, 'sample_rate must be a positive integer' unless sample_rate.kind_of?(Integer) && sample_rate > 0
    end
  end

  autonotify(:service) do
    ['pianoteq']
  end
end