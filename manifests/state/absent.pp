class pianoteq::state::absent {
  service { 'pianoteq':
    ensure => stopped,
    enable => false
  }

  package { 'pianoteq':
    ensure => absent,
    require => Service['pianoteq']
  }
}
