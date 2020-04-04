#
class psick::ruby::bundler (
  $ensure = 'present',

  Boolean $manage      = $::psick::manage,
  Boolean $noop_manage = $::psick::noop_manage,
  Boolean $noop_value  = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    package { 'bundler':
      ensure   => $ensure,
      provider => 'gem',
    }
  }
}
