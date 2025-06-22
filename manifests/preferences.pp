class pianoteq::preferences {
  $audio_setup = lookup('pianoteq::audio_setup', { 'default_value' => undef })
  if $audio_setup {
    pianoteq_audio_pref { 'audio-setup':
      device_name => $audio_setup['device_name'],
      device_type => $audio_setup['device_type'],
      buffer_size => $audio_setup['buffer_size'],
      sample_rate => $audio_setup['sample_rate']
    }
  }

  $midi_setup = lookup('pianoteq::midi_setup', { 'default_value' => undef })
  if $midi_setup {
    pianoteq_midi_pref { 'midi-setup':
      listen_all => $midi_setup['listen_all'],
      devices => $midi_setup['devices']
    }
  }

  $multicore = lookup('pianoteq::multicore', { 'default_value' => undef })
  if $multicore {
    pianoteq_value_pref { 'multicore':
      value => $multicore
    }
  }

  $voices = lookup('pianoteq::voices', { 'default_value' => undef })
  if $voices {
    pianoteq_value_pref { 'voices':
      value => $voices
    }
  }

  $voices_thresh = lookup('pianoteq::voices_thresh', { 'default_value' => undef })
  if $voices_thresh {
    pianoteq_value_pref { 'voices_thresh':
      value => $voices_thresh
    }
  }

  $engine_rate = lookup('pianoteq::engine_rate', { 'default_value' => undef })
  if $engine_rate {
    pianoteq_value_pref { 'engine_rate':
      value => $engine_rate
    }
  }

  #/var/opt/pianoteq/8.4.1
  $user_root_folder = lookup('pianoteq::user_root_folder', { 'default_value' => undef })
  if $user_root_folder {
    pianoteq_value_pref { 'user_root_folder':
      value => $user_root_folder
    }
  }

  $welcome_done = lookup('pianoteq::welcome_done', { 'default_value' => undef })
  if $welcome_done {
    pianoteq_value_pref { 'welcome-done':
      value => $welcome_done
    }
  }

  $midi_archive_enabled = lookup('pianoteq::midi_archive_enabled', { 'default_value' => undef })
  if $midi_archive_enabled {
    pianoteq_value_pref { 'midiArchiveEnabled':
      value => $midi_archive_enabled
    }
  }

  $force_touchscreen_mode = lookup('pianoteq::force_touchscreen_mode', { 'default_value' => undef })
  if $force_touchscreen_mode {
    pianoteq_value_pref { 'force_touchscreen_mode':
      value => $force_touchscreen_mode
    }
  }
}
