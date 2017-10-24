# @class openswan
#
class psick::openswan (

  Variant[Boolean,String]    $ensure = present,
  Enum['psick']              $module = 'psick',

  Hash                       $connections_hash = {},
) {

  # Intallation management
  case $module {
    'psick': {
      contain ::psick::openswan::tp
      $connections_hash.each |$k,$v| {
        psick::openswan::connection { $k:
          options => $v,
        }
      }
    }
    default: {
      contain ::openswan
    }
  }

}
