# @class openswan
#
class psick::openswan (

  Psick::Ensure   $ensure                   = 'present',
  Boolean         $manage                   = $::psick::manage,

  String                     $module        = 'psick',
  Boolean         $no_noop                  = false,

  Hash                       $connections    = {},
  Hash                       $setup_options  = {},
  String                     $setup_template = 'psick/openswan/ipsec.conf.erb',
) {

  # We declare resources only if $manage = true
  if $manage {

    # If no_noop is set it's enforced, unless psick::noop_mode is
    if !$::psick::noop_mode and $no_noop {
      info('Forced no-noop mode in psick::grafana')
      noop(false)
    }

    case $module {
      'psick': {
        contain ::psick::openswan::tp
      }
      'tp_profile': {
        contain ::tp_profile::openswan
      }
      default: {
        contain ::openswan
      }
    }
    $connections.each |$k,$v| {
      psick::openswan::connection { $k:
        * => $v,
      }
    }

    if $setup_template != '' {
      $content = template($setup_template)
      tp::conf { 'openswan':
        content => $content,
      }
    }
  }
}
