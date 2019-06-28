# @class openvpn
#
class psick::openvpn (

  Variant[Boolean,String]    $ensure         = 'present',
  Enum['psick']              $module         = 'psick',

  Hash                       $connections    = {},
  Hash                       $deploy_exports = {},
  Hash                       $deploy_clients = {},
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
      $deploy_exports.each |$k,$v| {
        openvpn::deploy::export { $k:
          * => $v,
        }
      }
      $deploy_clients.each |$k,$v| {
        openvpn::deploy::client { $k:
          * => $v,
        }
      }
      contain ::openvpn
    }
  }

}
