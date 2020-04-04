# @class openvpn
#
class psick::openvpn (

  Variant[Boolean,String]    $ensure         = 'present',
  Enum['tp_profile','openvpn'] $module       = 'tp_profile',

  # Used with module = psick
  Hash                       $connections    = {},
  Hash                       $deploy_exports = {},
  Hash                       $deploy_clients = {},

  # Used with module = openvpn (vopupuli one as reference)
  Hash                              $ca_hash = {},
  Hash                          $ca_defaults = {},

  Hash                          $server_hash = {},
  Hash                      $server_defaults = {},

  Hash                          $revoke_hash = {},
  Hash                      $revoke_defaults = {},

  Hash                          $client_hash = {},
  Hash                      $client_defaults = {},

  Hash          $client_specific_config_hash = {},
  Hash      $client_specific_config_defaults = {},

  Hash                   $deploy_client_hash = {},
  Hash               $deploy_client_defaults = {},

  Hash                   $deploy_export_hash = {},
  Hash               $deploy_export_defaults = {},

  Boolean              $manage               = $::psick::manage,
  Boolean              $noop_manage          = $::psick::noop_manage,
  Boolean              $noop_value           = $::psick::noop_value,

) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    case $module {
      'tp_profile': {
        contain ::tp_profile::openvpn
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
        $ca_hash.each |$k,$v| {
          openvpn::ca { $k:
            * => $ca_defaults + $v,
          }
        }
        $server_hash.each |$k,$v| {
          openvpn::server { $k:
            * => $server_defaults + $v,
          }
        }
        $revoke_hash.each |$k,$v| {
          openvpn::revoke { $k:
            * => $revoke_defaults + $v,
          }
        }
        $client_hash.each |$k,$v| {
          openvpn::client { $k:
            * => $client_defaults + $v,
          }
        }
        $client_specific_config_hash.each |$k,$v| {
          openvpn::client_specific_configs { $k:
            * => $client_specific_config_defaults + $v,
          }
        }
        $deploy_client_hash.each |$k,$v| {
          openvpn::deploy::client { $k:
            * => $deploy_client_defaults + $v,
          }
        }
        $deploy_export_hash.each |$k,$v| {
          openvpn::deploy::export { $k:
            * => $deploy_export_defaults + $v,
          }
        }
      }
    }
  }
}

