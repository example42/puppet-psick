# @summary Manage profiles specific to nodes, roles or any other group
# This class includes host/role specific profiles, they are applied after
# the base classes.
# Is exposes parameters that allow to define any class (from Psick,
# public modules or local profiles) to include as profile.
# For each different $::kernel value a differet entrypoint is exposed.
#
# For each of these $::kernel_classes parameters, it's expected an Hash of key-values:
# Keys can have any name, and are used as markers to allow overrides,
# exceptions management and customisations across Hiera's hierarchies.
# Values are actual class names to include in the node's catalog.
# They can be classes from psick module or any other module, both public
# ones (the typical component modules from the Forge) and private
# site profiles and modules.
#
# @example Manage common profiles classes for Linux and Windows:
#     psick::profiles::linux_classes:
#       webserver: '::psick::apache::tp'
#     psick::profiles::windows_classes:
#       webserver: '::iis'
#
# @example Disable inclusion of a class of the given marker. Here the
#   class marked as 'users' is set to an empty value and hence is
#   not included. Use this to manage exceptions and variations
#   overriding defaults set at more common Hiera layers.
#     psick::profiles::linux_classes:
#       'webserver': ''
#
# @example Disable the whole class (no resource from this class is declared)
#     psick::profiles::manage: false
#
# @param linux_classes Hash with the list of classes to include
#   as added profiles when $::kernel is Linux. Of each key-value
#   of the hash, the key is used as marker to eventually override
#   across Hiera hierarchies and the value is the name of the class
#   to actually include. Any key name can be used, but the value
#   must be a valid class existing the the $modulepath. If the value
#   is set to empty string ('') then the class of the relevant marker
#   is not included.
# @param windows_classes Hash with the list of classes to include
#   as added profiles when $::kernel is windows.
# @param solaris_classes Hash with the list of classes to include
#   as added profiles when $::kernel is Solaris.
# @param darwin_classes Hash with the list of classes to include
#   as added profiles when $::kernel is Darwin.
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
class psick::profiles (

  Psick::Class $linux_classes   = {},
  Psick::Class $windows_classes = {},
  Psick::Class $darwin_classes  = {},
  Psick::Class $solaris_classes = {},

  Boolean $manage               = $::psick::manage,
  Boolean $noop_manage          = $::psick::noop_manage,
  Boolean $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if !empty($linux_classes) and $::kernel == 'Linux' {
      $linux_classes.each |$n,$c| {
        if $c != '' {
          contain $c
        }
      }
    }
    if !empty($windows_classes) and $::kernel == 'windows' {
      $windows_classes.each |$n,$c| {
        if $c != '' {
          contain $c
        }
      }
    }
    if !empty($darwin_classes) and $::kernel == 'Darwin' {
      $darwin_classes.each |$n,$c| {
        if $c != '' {
          contain $c
        }
      }
    }
    if !empty($solaris_classes) and $::kernel == 'Solaris' {
      $solaris_classes.each |$n,$c| {
        if $c != '' {
          contain $c
        }
      }
    }
  }

}
