class pianoteq::state::present(String $version) {
  package { 'pianoteq':
    ensure => $version
  }

  transition { 'stop pianoteq service':
    resource   => Service['pianoteq'],
    attributes => { ensure => stopped },
    prior_to   => Class['pianoteq::preferences']
  }

  class { 'pianoteq::preferences':
    require => Package['pianoteq']
  }

  service { 'pianoteq':
    ensure => running,
    enable => true,
    hasrestart => true,
    require => [
      Package['pianoteq'],
      Class["pianoteq::preferences"]
    ]
  }

  $serial_number = lookup('pianoteq::serial_number', { 'default_value' => undef })
  if $serial_number and !$facts['pianoteq_activated'] {
    exec {'activate_pianoteq':
      command => "/usr/local/bin/pianoteq --headless --prefs /etc/opt/pianoteq/$(dpkg-query --showformat='\${Version}' --show pianoteq)/pianoteq.prefs --activate ${lookup('pianoteq::serial_number')}",
      require => Package['pianoteq'],
      notify => Service['pianoteq']
    }
  }
}
