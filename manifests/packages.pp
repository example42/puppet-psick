# @summary Generic class to manage packages
#
# This class exposes entrypoints, and data defaults to manage system
# packages, expressed via arrays or hashes. Be aware of risks of duplicated
# resources, when specifying here packages that might be installed by other
# modules or classes.
#
# @example Install an array of packages and use chocolatey as provider (on
# Windows)
#    psick::packages::resource_default_arguments:
#      provider: chocolatey
#    psick::packages::packages_list:
#      - "firefox"
#      - "flashplayerplugin"
#
# @param packages_default The packages installed by default (according to the
#   underlying OS and auto_conf settings)
# @param add_default_packages If to actually install the default packages
# @param packages_list An array of custom extra packages to install
# @param packages_hash An Hash passed to create packages resources. It has the
#   same function of $packages_list array, but allows specification of
#   parameters for package type.
# @param delete_unmanaged If true all packages not managed by Puppet
#    are automatically deleted. WARNING: this option may remove packages
#    you need on your systems!
# @param resource_default_arguments An hash of arguments to be used as default
#    in the package type.
#
class psick::packages (
  Array $packages_default         = [],
  Array $packages_list            = [],
  Hash $packages_hash             = {},
  Hash $resource_default_arguments = {},
  Boolean $add_default_packages   = true,
  Boolean $delete_unmanaged       = false,
) {

  $packages = $add_default_packages ? {
    true  => $packages_list + $packages_default,
    false => $packages_list,
  }

  Package {
    * => $resource_default_arguments,
  }

  $packages.each |$pkg| {
    ensure_packages($pkg)
  }

  $packages_hash.each |$k,$v| {
    package { $k:
      * => $v,
    }
  }

  if $delete_unmanaged {
    resources { 'package':
      purge              => true,
    }
  }
}
