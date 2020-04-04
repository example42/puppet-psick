# @class mariadb
#
class psick::mariadb (

  Variant[Boolean,String]    $ensure = present,
  Enum['tp_profile']         $module = 'tp_profile',

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
        contain ::tp_profile::mariadb
        contain ::psick::mariadb::root_password
        $user_hash.each |$k,$v| {
          psick::mariadb::user { $k:
            * => $v,
          }
        }
        $query_hash.each |$k,$v| {
          psick::mariadb::query { $k:
            * => $v,
          }
        }
        $sqlfile_hash.each |$k,$v| {
          psick::mariadb::sqlfile { $k:
            * => $v,
          }
        }
        $grant_hash.each |$k,$v| {
          psick::mariadb::grant { $k:
            * => $v,
          }
        }
      }
      default: {
        contain ::mariadb
      }
    }
  }
}
