# Generic class to remove unnecessary packages
#
# @param packages_to_remove List of packages to remove
# @param packages_default Default list, OS dependent, of packages to remove
# @param remove_default_packages If to remove the packages_default
#
# @example Remove gcc from all systems
#   psick::hardening::packages::packages_to_remove:
#     - gcc
#
class psick::hardening::packages (
  Array $packages_to_remove,
  Array $packages_default,
  Boolean $remove_default_packages = true,
  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    $packages = $remove_default_packages ? {
      true  => $packages_to_remove + $packages_default,
      false => $packages_to_remove,
    }

    $packages.each |$pkg| {
      package { $pkg:
        ensure => absent,
      }
    }
  }
}
