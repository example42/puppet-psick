# @class mysql
#
class psick::mysql (

  Variant[Boolean,String]    $ensure = present,
  Enum['psick','puppetlabs'] $module = 'psick',

  Optional[Psick::Password]  $root_password = undef,

  Hash                       $sqlfile_hash  = {},
  Hash                       $grant_hash    = {},
  Hash                       $user_hash     = {},
  Hash                       $query_hash    = {},
) {

  # Intallation management
  case $module {
    'psick': {
      contain ::psick::mysql::tp
      contain ::psick::mysql::root_password
      user_hash.each |$k,$v| {
        psick::mysql::user { $k:
          * => $v,
        }
      }
      query_hash.each |$k,$v| {
        psick::mysql::query { $k:
          * => $v,
        }
      }
      sqlfile_hash.each |$k,$v| {
        psick::mysql::sqlfile { $k:
          * => $v,
        }
      }
      grant_hash.each |$k,$v| {
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
