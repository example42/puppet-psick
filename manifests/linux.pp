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

  # General switch. If false nothing is done.
  Boolean $manage = $::psick::manage,

  Hash $pre_classes,
  Hash $base_classes,
  Hash $profiles,

) {

  if $pre_classes ! = {} and $manage {
    $pre_classes.each |$k,$v| {
      contain $v
    }
  }
  if $base_classes ! = {} and $manage {
    $base_classes.each |$k,$v| {
      contain $v
    }
  }
  if $profiles ! = {} and $manage {
    $profiles.each |$k,$v| {
      contain $v
    }
  }

}
