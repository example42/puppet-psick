# @class openvpn
#
class psick::openvpn (

  Variant[Boolean,String]    $ensure         = 'present',
  Enum['psick']              $module         = 'psick',

  Hash                       $connections    = {},
) {

  # Intallation management
  case $module {
    'psick': {
      contain ::psick::openvpn::tp
      $connections.each |$k,$v| {
        psick::openvpn::connection { $k:
          * => $v,
        }
      }
    }
    default: {
      contain ::openvpn
    }
  }

}
