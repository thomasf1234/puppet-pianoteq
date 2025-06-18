class pianoteq {
  $ensure = lookup("pianoteq::ensure")

  include "pianoteq::state::${ensure}"
}

