# @class openswan
#
class psick::openswan (

  Psick::Ensure   $ensure                   = 'present',

  String                     $module        = 'tp_profile',

  Hash                       $connections    = {},
  Hash                       $setup_options  = {},
  String                     $setup_template = 'psick/openswan/ipsec.conf.erb',

  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
) {

  # We declare resources only if $manage = true
  if $manage {

    if $noop_manage {
      noop($noop_value)
    }

    case $module {
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
