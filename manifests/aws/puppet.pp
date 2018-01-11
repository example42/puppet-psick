#
class psick::aws::puppet (
  String $ensure                = 'present',
  String $region                = $::psick::aws::region,
  Array $install_modules        = [ 'puppetlabs/aws' , 'example42/psick' ],
  String $module_user           = 'root',
) {

  $install_modules.each | $mod | {
    psick::puppet::module { $mod:
      user   => $module_user,
    }
  }

}
