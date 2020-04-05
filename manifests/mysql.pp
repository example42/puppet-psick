# @class mysql
#
class psick::mysql (

  Variant[Boolean,String]    $ensure = present,
  Enum['tp_profile','puppetlabs'] $module   = 'tp_profile',

  Optional[Psick::Password]  $root_password = undef,

  Hash                       $sqlfile_hash  = {},
  Hash                       $grant_hash    = {},
  Hash                       $user_hash     = {},
  Hash                       $query_hash    = {},

  Boolean             $manage               = $::psick::manage,
  Boolean             $noop_manage          = $::psick::noop_manage,
  Boolean             $noop_value           = $::psick::noop_value,

) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    # Intallation management
    case $module {
      'tp_profile': {
        contain ::tp_profile::mysql
        contain ::psick::mysql::root_password
        $user_hash.each |$k,$v| {
          psick::mysql::user { $k:
            * => $v,
          }
        }
        $query_hash.each |$k,$v| {
          psick::mysql::query { $k:
            * => $v,
          }
        }
        $sqlfile_hash.each |$k,$v| {
          psick::mysql::sqlfile { $k:
            * => $v,
          }
        }
        $grant_hash.each |$k,$v| {
          psick::mysql::grant { $k:
            * => $v,
          }
        }
      }
      default: {
        contain ::mysql
      }
    }
  }
}
