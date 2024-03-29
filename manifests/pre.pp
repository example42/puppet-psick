# This class includes prerequisite classes, applied before base classes and profiles.
# Is exposes parameters that allow to define any class (from Psick,
# public modules or local profiles) to include before anything else.
# For each different $facts['kernel'] value a differet entrypoint is exposed.
#
# For each of these parameters, is expected an Hash of key - values:
# keys can have any name, and are used as markers to allow overrides,
# exceptions management and customisations across Hiera's hierarchies.
# values are actual class names to include in the node's catalog.
# They can be classes from psick module or any other module, both public
# ones (the typical component modules from the Forge) and private
# site profiles and modules.
#
# @example Manage prerequisites classes for Linux and Windows:
#     psick::pre::linux_classes:
#       'repo': '::psick::repo'
#       'proxy': '::psick::proxy'
#       'users': '::profile::users'
#     psick::pre::windows_classes:
#       'repo': '::chocolatey'
#       'hostname': '::psick::hostname'
#
# @example Disable inclusion of a class of the given marker. Here the
#   class marked as 'users' is set to an empty value and hence is
#   not included. Use this to manage exceptions and variations
#   overriding defaults set at more common Hiera layers.
#     psick::pre::linux_classes:
#       'repo': '::psick::repo'
#       'proxy': '::psick::proxy'
#       'users': ''
#
# @example Disable the whole class (no resource from this class is declared)
#     psick::pre::manage: false
#
# @param linux_classes Hash with the list of classes to include
#   before the base classes when $facts['kernel'] is Linux. Of each key-value
#   of the hash, the key is used as marker to eventually override
#   across Heirq hierarchies and the value is the name of the class
#   to actually include. Any key name can be used, but the value
#   must be a valid class (of psick, of public modules or local profiles)
#   existing the the $modulepath. If the value is set to empty string ('')
#   then the class of the relevant marker is not included.
# @param windows_classes Hash with the list of classes to include
#   before the base classes when $facts['kernel'] is windows.
# @param solaris_classes Hash with the list of classes to include
#   before the base classes when $facts['kernel'] is Solaris.
# @param darwin_classes Hash with the list of classes to include
#   before the base classes when $facts['kernel'] is Darwin.
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
class psick::pre (

  Psick::Class $linux_classes   = {},
  Psick::Class $windows_classes = {},
  Psick::Class $darwin_classes  = {},
  Psick::Class $solaris_classes = {},

  Boolean $manage               = $psick::manage,
  Boolean $noop_manage          = $psick::noop_manage,
  Boolean $noop_value           = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if !empty($linux_classes) and $facts['kernel'] == 'Linux' {
      $linux_classes.each |$n,$c| {
        if $c != '' {
          contain $c
        }
      }
    }
    if !empty($windows_classes) and $facts['kernel'] == 'windows' {
      $windows_classes.each |$n,$c| {
        if $c != '' {
          contain $c
        }
      }
    }
    if !empty($darwin_classes) and $facts['kernel'] == 'Darwin' {
      $darwin_classes.each |$n,$c| {
        if $c != '' {
          contain $c
        }
      }
    }
    if !empty($solaris_classes) and $facts['kernel'] == 'Solaris' {
      $solaris_classes.each |$n,$c| {
        if $c != '' {
          contain $c
        }
      }
    }
  }
}
