# @class virtualbox
#
class psick::virtualbox (

  Psick::Ensure   $ensure                   = 'present',

  String          $module                   = 'tp_profile',

  Optional[Psick::Password]  $root_password = undef,

  Hash                       $network_hash  = {},
  Hash                       $vm_hash       = {},

  Boolean          $manage                  = $::psick::manage,
  Boolean          $noop_manage             = $::psick::noop_manage,
  Boolean          $noop_value              = $::psick::noop_value,
) {

  # We declare resources only if $manage = true
  if $manage {

    if $noop_manage {
      noop($noop_value)
    }

    # Intallation management
    case $module {
      'tp_profile': {
        contain tp_profile::virtualbox
      }
      default: {
        contain $module
      }
    }

    $vm_hash.each |$k,$v| {
      psick::virtualbox::vm { $k:
        * => $v,
      }
    }
    $network_hash.each |$k,$v| {
      psick::virtualbox::network { $k:
        * => $v,
      }
    }
  }
}
