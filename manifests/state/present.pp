class pianoteq::state::present {
  file { '/tmp/pianoteq8.4.1_amd64.deb':
    ensure => 'file',
    source => 'http://192.168.1.15:8000/pianoteq8.4.1_amd64.deb'
  }

  package { 'pianoteq':
    ensure => installed,
    source => '/tmp/pianoteq8.4.1_amd64.deb',
    require => File['/tmp/pianoteq8.4.1_amd64.deb']
  }

  exec {'stop_pianoteq':
    command => "/usr/bin/systemctl stop pianoteq",
    require => Package['pianoteq']
  }

  class {'pianoteq::preferences':
    require => Exec['stop_pianoteq']
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
      command => "/usr/local/bin/pianoteq --headless --prefs /etc/opt/pianoteq/8.4.1/pianoteq.prefs --activate ${lookup('pianoteq::serial_number')}",
      require => Package['pianoteq'],
      notify => Service['pianoteq']
    }
  }
}
