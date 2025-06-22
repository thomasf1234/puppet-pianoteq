class pianoteq::state::absent {
  service { 'pianoteq':
    ensure => stopped,
    enable => false
  }

  package { 'pianoteq':
    ensure => purged,
    require => Service['pianoteq']
  }
}
