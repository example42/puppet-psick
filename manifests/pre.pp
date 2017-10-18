# This class includes prerequisite classes, applied before base classes and profiles.
# Is exposes parameters that allow to define any class (from Psick,
# public modules or local profiles) to include before anything else.
# For each different $::kernel value a differet entrypoint is exposed.
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
# @param manage If to actually manage any resource. Set to false to disable
#   any effect of this psick::pre class.
#
# @param linux_classes Hash with the list of classes to include
#   before the base classes when $::kernel is Linux. Of each key-value
#   of the hash, the key is used as marker to eventually override
#   across Heirq hierarchies and the value is the name of the class
#   to actually include. Any key name can be used, but the value
#   must be a valid class (of psick, of public modules or local profiles)
#   existing the the $modulepath. If the value is set to empty string ('')
#   then the class of the relevant marker is not included.
#
# @param windows_classes Hash with the list of classes to include
#   before the base classes when $::kernel is windows.
#
# @param solaris_classes Hash with the list of classes to include
#   before the base classes when $::kernel is Solaris.
#
# @param darwin_classes Hash with the list of classes to include
#   before the base classes when $::kernel is Darwin.
#
class psick::pre (

  Psick::Class $linux_classes   = {},
  Psick::Class $windows_classes = {},
  Psick::Class $darwin_classes  = {},
  Psick::Class $solaris_classes = {},

  Boolean $manage = $::psick::manage,

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
