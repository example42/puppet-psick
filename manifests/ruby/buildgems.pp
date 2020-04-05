# This class installs the packages needed to build gems
#
class psick::ruby::buildgems (
  Array $packages = [],

  Boolean $manage      = $::psick::manage,
  Boolean $noop_manage = $::psick::noop_manage,
  Boolean $noop_value  = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    $packages.each |$pkg| {
      ensure_packages($pkg)
    }
  }
}
