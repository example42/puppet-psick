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

  if ::tp::is_something($pre_classes) and $pre_manage {
    case $pre_classes {
      Array: {
        $pre_classes.each |$class| {
          contain $class
        }
      }
      Hash: {
        $pre_classes.each |$name,$class| {
          contain $class
        }
      }
      default: {}
    }
  }

  if ::tp::is_something($base_classes) and $base_manage {
    case $base_classes {
      Array: {
        $base_classes.each |$class| {
          contain $class
        }
      }
      Hash: {
        $base_classes.each |$name,$class| {
          contain $class
        }
      }
      default: {}
    }
  }

  if ::tp::is_something($monitor_classes) and $monitor_manage {
    case $monitor_classes {
      Array: {
        $monitor_classes.each |$class| {
          contain $class
        }
      }
      Hash: {
        $monitor_classes.each |$name,$class| {
          contain $class
        }
      }
      default: {}
    }
  }

  if ::tp::is_something($profiles) and $profiles_manage {
    case $profiles {
      Array: {
        $profiles.each |$class| {
          contain $class
        }
      }
      Hash: {
        $profiles.each |$name,$class| {
          contain $class
        }
      }
      default: {}
    }
  }

}
