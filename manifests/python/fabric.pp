# This class installs fabric
#
class psick::python::fabric (
  String $ensure = 'present',

  Boolean $manage      = $psick::manage,
  Boolean $noop_manage = $psick::noop_manage,
  Boolean $noop_value  = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    package { 'fabric':
      ensure => $ensure,
    }
  }
}
