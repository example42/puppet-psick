# The prerequisite classes. Applied before base classes and profiles.
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
class psick::pre (

  Boolean $manage = $::psick::manage,

  Psick::Class $linux_classes,
  Psick::Class $windows_classes,
  Psick::Class $darwin_classes,
  Psick::Class $solaris_classes,

) {

  if $manage {
    if !empty($linux_classes) {
      $linux_classes.each |$n,$c| {
        if $c != '' {
          contain $c
          Class[$c] -> Class['psick::base']
        }
      }
    }
    if !empty($windows_classes) {
      $windows_classes.each |$n,$c| {
        if $c != '' {
          contain $c
          Class[$c] -> Class['psick::base']
        }
      }
    }
    if !empty($darwin_classes) {
      $darwin_classes.each |$n,$c| {
        if $c != '' {
          contain $c
          Class[$c] -> Class['psick::base']
        }
      }
    }
    if !empty($solaris_classes) {
      $solaris_classes.each |$n,$c| {
        if $c != '' {
          contain $c
          Class[$c] -> Class['psick::base']
        }
      }
    }
  }

}
