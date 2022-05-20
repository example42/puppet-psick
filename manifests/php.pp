# @class php
#
class psick::php (

  Variant[Boolean,String] $ensure = present,
  String                  $module = 'psick',

  String                  $module_prefix = 'php-',
  String                  $pear_module_prefix = 'php-pear-',

  Hash                    $module_hash      = {},
  Hash                    $pear_module_hash = {},
  Hash                    $pear_config_hash = {},

  Boolean                 $manage           = $psick::manage,
  Boolean                 $noop_manage      = $psick::noop_manage,
  Boolean                 $noop_value       = $psick::noop_value,

) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    case $module {
      'tp_profile': {
        contain tp_profile::php
        $module_hash.each |$k,$v| {
          psick::php::module { $k:
            * => $v,
          }
        }
        $pear_module_hash.each |$k,$v| {
          psick::php::pear::module { $k:
            * => $v,
          }
        }
        $pear_config_hash.each |$k,$v| {
          psick::php::pear::config { $k:
            * => $v,
          }
        }
      }
      'psick': {
        contain psick::php::tp
        $module_hash.each |$k,$v| {
          psick::php::module { $k:
            * => $v,
          }
        }
        $pear_module_hash.each |$k,$v| {
          psick::php::pear::module { $k:
            * => $v,
          }
        }
        $pear_config_hash.each |$k,$v| {
          psick::php::pear::config { $k:
            * => $v,
          }
        }
      }
      default: {
        contain php
      }
    }
  }
}
