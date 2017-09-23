# This class manages sysctl
# It uses duritong-sysctl module
# Hiera data should be in this format:
# psick::sysctl::settings_hash:
#   net.ipv4.tcp_keepalive_time: 900
#   net.ipv4.conf.default.arp_filter: 1
#
class psick::sysctl (
  Boolean         $manage                  = $::psick::manage,
  Hash            $settings_hash           = {},
  Hash            $settings_auto_conf_hash = {},
  String          $module                  = 'default',
) {

  $all_settings = $settings_auto_conf_hash + $settings_hash

  if $manage and $all_settings != {} {
    $all_settings.each |$k,$v| {
      case $module {
        'duritong': {
          sysctl::value { $k: value => $v }
        }
        'thias': {
          sysctl { $k: value => $v }
        }
        'herculesteam': {
          sysctl { $k: value => $v }
        }
        default: {
          notify { "sysctl ${module} module not supported":
            message => "Module ${module} not currently not supported. Feel free to contribute to its integration!",
          }
        }
      }
    }
  }
}
