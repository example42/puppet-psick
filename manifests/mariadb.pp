# @class mariadb
#
class psick::mariadb (

  Variant[Boolean,String]    $ensure = present,
  Enum['psick']              $module = 'psick',

  Optional[Psick::Password]  $root_password = undef,

  Hash                       $sqlfile_hash  = {},
  Hash                       $grant_hash    = {},
  Hash                       $user_hash     = {},
  Hash                       $query_hash    = {},
) {

  # Intallation management
  case $module {
    'psick': {
      contain ::psick::mariadb::tp
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
