# @summary Generic class to manage packages
#
# This class exposes entrypoints, and data defaults to manage system
# packages, expressed via arrays or hashes. Be aware of risks of duplicated
# resources, when specifying here packages that might be installed by other
# modules or classes.
# You can use different parameters to manage packages, they all manage
# package resources, using different approaches:
# - $packages_list An Array of packages to install. If $add_default_packages
#                  if true, to this list is added the $packages_default array
# - $packages_hash An Hash of packages to manage, where keys are package names
#                  and values are arguments passed to the package resurce
# - $packages_osfamily_hash An Hash of packages to manage, where keys are the
#                           osfamily and values are a String, an Array of an
#                           Hash of packages to manage.
#
# @example Install an array of packages and use chocolatey as provider (on
# Windows)
#    psick::packages::resource_default_arguments:
#      provider: chocolatey
#    psick::packages::packages_list:
#      - "firefox"
#      - "flashplayerplugin"
#
# @example Alternative approach with different package names for different OS
#   families. The list of packages for each $osfamily can be either a string,
#   an array or an hash (allowing you to specify extra params for each package):
#    psick::packages::packages_osfamily_hash:
#      RedHat:
#        - net-tools
#        - telnet
#      Debian: telnet
#      windows:
#        firefox:
#          provider: chocolatey
#
# @example Purge all the packages not managed explicitly by Puppet.
#          Warning: This is a very dangerous option, as it can remove necessary
#          system packages from your nodes
#    psick::packages::delete_unmanaged: true
#    
# @param packages_list An array of custom extra packages to install
# @param packages_default The packages installed by default (according to the
#   underlying OS settings)
# @param add_default_packages If to actually install the default packages
# @param packages_hash An Hash passed to create packages resources. It has the
#   same function of $packages_list array, but allows specification of
#   parameters for package type.
# @param $packages_osfamily_hash This hash is an alternative way to specify the
#   packages to install for each osfamily. The key of the Hash is the Osfamily,
#   the relevant value can be a String, an Array or an Hash of packages to install
# @param delete_unmanaged If true all packages not managed by Puppet
#    are automatically deleted. WARNING: this option may remove packages
#    you need on your systems!
# @param resource_default_arguments An hash of arguments to be used as default
#    in the package type.
# @param manage If to actually manage any resource in this class. If false no
#               resource is managed. Default value is taken from main psick class.
# @param noop_manage If to use the noop() function for all the resources provided
#                    by this class. If this is true the noop function is called
#                    with $noop_value argument. This overrides any other noop setting
#                    (either set on client's puppet.conf or by noop() function in
#                    main psick class). Default from psick class.
# @param noop_value The value to pass to noop() function if noop_manage is true.
#                   It applies to all the resources (and classes) declared in this class
#                   If true: noop metaparamenter is set to true, resources are not applied
#                   If false: noop metaparameter is set to false, and any eventual noop
#                   setting is overridden: resources are always applied.
#                   Default from psick class.
#
#
class psick::packages (
  Array $packages_list             = [],
  Array $packages_default          = [],
  Boolean $add_default_packages    = true,

  Hash $packages_hash              = {},

  Hash $packages_osfamily_hash     = {},

  Hash $resource_default_arguments = {},
  Boolean $delete_unmanaged        = false,

  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,

) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    Package {
      * => $resource_default_arguments,
    }

    # Purge umanaged packages if $delete_unmanaged == true (DANGER!)
    if $delete_unmanaged {
      resources { 'package':
        purge => true,
      }
    }

    # Packages management based on $packages_list
    $packages = $add_default_packages ? {
      true  => $packages_list + $packages_default,
      false => $packages_list,
    }
    $packages.each |$pkg| {
      ensure_packages($pkg)
    }

    # Packages management based on $packages_hash
    $packages_hash.each |$k,$v| {
      package { $k:
        * => $v,
      }
    }

    # Packages management based on $packages_osfamily_hash
    $packages_osfamily_hash.each |$k,$v| {
      if $::osfamily == $k {
        case $v {
          Array: {
            ensure_packages($v)
          }
          Hash: {
            $v.each |$kk,$vv| {
              package { $kk:
                * => $vv,
              }
            }
          }
          String: {
            package { $v:
              ensure => present,
            }
          }
          default: {
            fail("Unsupported type for ${v}. Valid types are String, Array, Hash")
          }
        }
      }
    }
  }
}
