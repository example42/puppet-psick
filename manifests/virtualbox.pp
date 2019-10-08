# @class virtualbox
#
class psick::virtualbox (

  Psick::Ensure   $ensure                   = 'present',
  Boolean         $manage                   = $::psick::manage,

  String                     $module = 'psick',
  Boolean         $no_noop                  = false,

  Optional[Psick::Password]  $root_password = undef,

  Hash                       $network_hash  = {},
  Hash                       $vm_hash    = {},
) {

  # We declare resources only if $manage = true
  if $manage {

    # If no_noop is set it's enforced, unless psick::noop_mode is
    if !$::psick::noop_mode and $no_noop {
      info('Forced no-noop mode in psick::grafana')
      noop(false)
    }

    # Intallation management
    case $module {
      'psick': {
        contain psick::virtualbox::tp
      }
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
