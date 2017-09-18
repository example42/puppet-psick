# The base classes. Applied before profiles.
# 
# @example Manage Linux base classes:
#   psick::base::linux_classes:
#     'repo': '::psick::repo'
#     'proxy': '::psick::proxy'
#
# @example Completely disable management of any resource from this class
#   psick::base::manage: false
#
# @param manage If to actually manage any resource. Set to false to disable
#   any effect of the base psick.
#
class psick::base (

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
          Class['psick::pre'] -> Class[$c]
        }
      }
    }
    if !empty($windows_classes) {
      $windows_classes.each |$n,$c| {
        if $c != '' {
          contain $c
          Class['psick::pre'] -> Class[$c]
        }
      }
    }
    if !empty($darwin_classes) {
      $darwin_classes.each |$n,$c| {
        if $c != '' {
          contain $c
          Class['psick::pre'] -> Class[$c]
        }
      }
    }
    if !empty($solaris_classes) {
      $solaris_classes.each |$n,$c| {
        if $c != '' {
          contain $c
          Class['psick::pre'] -> Class[$c]
        }
      }
    }
  }

}
