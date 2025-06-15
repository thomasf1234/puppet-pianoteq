class pianoteq {
  #https://dev.to/betadots/the-ruby-side-of-puppet-part-3-custom-types-and-providers-4hma
  file { '/tmp/pianoteq8.4.1_amd64.deb': 
    ensure => 'file',
    source => 'http://192.168.1.15:8000/pianoteq8.4.1_amd64.deb'
  }

  package { 'pianoteq':
    ensure => installed,
    source => '/tmp/pianoteq8.4.1_amd64.deb',
    require => [
      File['/tmp/pianoteq8.4.1_amd64.deb']
    ]
  }

  # Pianoteq to install to /opt/pianoteq/8.4.1/
  # sudo puppet resource --debug --modulepath=./modules pianoteq_pref

  pianoteq_audio_pref { 'audio-setup':
    device_name => 'Audient iD14, USB Audio; Front output / input',
    buffer_size => 256,
    device_type => 'ALSA',
    sample_rate => 96000
  }

  pianoteq_midi_pref { 'midi-setup':
     listen_all => false,
     devices => [
        { name => 'Midi Through Port-0', client_port => 14 }
     ]
  }

  pianoteq_value_pref { 'multicore':
     value => max
  }

  pianoteq_value_pref { 'voices':
     value => 96
  }

  pianoteq_value_pref { 'voices_thresh':
     value => 100
  }

  pianoteq_value_pref { 'engine_rate':
     value => 32000
  }

  pianoteq_value_pref { 'user_root_folder':
     value => '/var/opt/pianoteq/8.4.1'
  }

  pianoteq_value_pref { 'welcome-done':
      value => true
  }

  pianoteq_value_pref { 'midiArchiveEnabled':
      value => true
  }

  # pianoteq_value_pref { 'serial':
  #     value => lookup('pianoteq::serial_number')
  # }

  pianoteq_value_pref { 'force_touchscreen_mode':
      value => false
  }

  # use fact hash
  if !$facts['pianoteq_activated'] {
    notify {'WARNING':
      message => "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    }
  }

  service { 'pianoteq':
    ensure => running,
    enable => true,
    hasrestart => true,
    #subscribe => File['~/.config/Modartt/Pianoteq84.prefs'],
    require => Package['pianoteq']
  }
}

# TODO : Add FACTS
# pianoteq --headless --prefs /etc/opt/pianoteq/8.4.1/pianoteq.prefs --serve 0.0.0.0:8081
