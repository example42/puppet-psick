#
class psick::aws::puppet (
  String $ensure                = 'present',
  String $region                = $::psick::aws::region,
  Array $install_modules        = [ 'puppetlabs/aws' , 'example42/psick' ],
  String $module_user           = 'root',

  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    $install_modules.each | $mod | {
      psick::puppet::module { $mod:
        user   => $module_user,
      }
    }
  }
}
