#
class psick::ruby (
  $ensure = 'present',

  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    tp::install { 'ruby':
      ensure => $ensure,
    }
  }
}
