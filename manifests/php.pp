# @class php
#
class psick::php (

  Variant[Boolean,String]    $ensure = present,
  Enum['psick']              $module = 'psick',

  String                     $module_prefix = 'php-',
  String                     $pear_module_prefix = 'php-pear-',

  Hash                       $module_hash      = {},
  Hash                       $pear_module_hash = {},
  Hash                       $pear_config_hash = {},
) {

  # Intallation management
  case $module {
    'psick': {
      contain ::psick::php::tp
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
      contain ::php
    }
  }

}
