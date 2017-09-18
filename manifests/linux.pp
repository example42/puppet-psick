# The psick linux class wrapper base psick profile included on all linux systems.
# 
# It exposes a list of parameters which define the name of the class to use for
# different common tasks. If the name is empty (as always by default)
# no class is included.
#
# @example Manage linux prerequisites and base classes:
#   psick::linux::pre_classes:
#     'repo': '::psick::repo'
#     'proxy': '::psick::proxy'
#   psick::linux::base_classes:
#
# @example Completely disable management of any resource from this class
#   psick::linux::manage: false
#
# @param manage If to actually manage any resource. Set to false to disable
#   any effect of the base psick.
#
class psick::linux (

  Boolean $pre_manage = $::psick::manage,
  Variant[Hash,Array] $pre_classes,

  Boolean $base_manage = $::psick::manage,
  Variant[Hash,Array] $base_classes,

  Boolean $monitor_manage = $::psick::manage,
  Variant[Hash,Array] $monitor_classes,

  Boolean $profiles_manage = $::psick::manage,
  Variant[Hash,Array] $profiles,

) {

  if !empty($pre_classes) and $pre_manage {
    case $pre_classes {
      Array: {
        $pre_classes.each |$c| {
          contain $c
        }
        notify { 'pre_array': }
      }
      Hash: {
        $pre_classes.each |$n,$c| {
          contain $c
        }
        notify { 'pre_hash': }
      }
      default: {}
    }
  }

  if !empty($base_classes) and $base_manage {
    case $base_classes {
      Array: {
        $base_classes.each |$c| {
          contain $c
        }
        notify { 'base_array': }
      }
      Hash: {
        $base_classes.each |$n,$c| {
          contain $c
        }
        notify { 'base_hash': }
      }
      default: {}
    }
  }

  if !empty($monitor_classes) and $monitor_manage {
    case $monitor_classes {
      Array: {
        $monitor_classes.each |$c| {
          contain $c
        }
      }
      Hash: {
        $monitor_classes.each |$n,$c| {
          contain $c
        }
      }
      default: {}
    }
  }

  if !empty($profiles) and $profiles_manage {
    case $profiles {
      Array: {
        $profiles.each |$c| {
          contain $c
        }
      }
      Hash: {
        $profiles.each |$n,$c| {
          contain $c
        }
      }
      default: {}
    }
  }

}
