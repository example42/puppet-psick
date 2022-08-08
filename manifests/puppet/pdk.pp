#
class psick::puppet::pdk (
  Psick::Ensure $ensure = 'present',
  Boolean $auto_prereq             = $psick::auto_prereq,
  Boolean $manage                  = $psick::manage,
  Boolean $noop_manage             = $psick::noop_manage,
  Boolean $noop_value              = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $auto_prereq {
      include psick::ruby::buildgems
    }

    package { 'pdk':
      ensure => $ensure,
    }
  }
}
