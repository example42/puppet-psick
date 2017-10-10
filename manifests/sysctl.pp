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
  String          $module                  = 'psick',
  String          $template                = 'psick/generic/inifile.erb',
  String          $target_file             = '/etc/sysctl.conf',
) {

  $all_settings = $settings_auto_conf_hash + $settings_hash

  if $manage and $all_settings != {} {
    if $module == 'psick' {
      $parameters = $all_settings
      file { $target_file:
        content => psick::template($template,$parameters),
        notify  => Exec['psick refresh sysctl'],
      }
      exec { 'psick refresh sysctl':
        refreshonly => true,
        command     => 'sysctl -p /etc/sysctl.conf',
      }
    } else {
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
            notify { "sysctl ${module} module not supported. Can't set sysctl ${k}":
              message => "Module ${module} not currently not supported. Feel free to contribute to its integration!",
            }
          }
        }
      }
    }
  }
}
