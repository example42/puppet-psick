# This class manages backup.
#
# @example Include the legato class for backup:
#   psick::backup::legato_class: '::psick::backup::legato'
#
# @params legato_class Name of the class that manages Legato Installation
#
class psick::backup (
  String $legato_class   = '',

  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $legato_class != '' {
      include $legato_class
    }

  }
}
