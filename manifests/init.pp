class pianoteq {
  $ensure = lookup("pianoteq::ensure")

  case $facts['os']['name'] {
    'Debian', 'Ubuntu':  {
      case $ensure {
        'latest', 'present', /\d+/:  {
          class { 'pianoteq::state::present':
            version => $ensure
          }
        }
        'absent': { 
          include pianoteq::state::absent
        }
        'purged': { 
          include pianoteq::state::purged
        }
        default:  {
          fail("${ensure} is not supported please use a version number or one of (absent,purged)") 
        }
      }
    }
    default:  {
      fail("${facts['os']['name']} is not supported") 
    }
  }
}

