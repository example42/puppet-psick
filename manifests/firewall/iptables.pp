# Essential firewall class based on simple iptables-save file
#
# @param preserve_rules_on_restore When true the existing rules are not removed
#   when changes are applied to the iptables configuration file. This is necessary
#   on nodes where containers are running, where relevant rules are added by Docker,
#   Kubernetes or similar services.
class psick::firewall::iptables (
  String $package_name,
  String $service_name,
  Optional[String] $service_name_v6,
  String $config_file_path,
  String $config_file_path_v6,
  String $rules_template                 = 'psick/firewall/iptables.erb',
  String $rules_template_v6              = 'psick/firewall/iptables6.erb',
  Array $extra_rules                     = [ ],
  Array $extra_rules_v6                  = [ ],
  Array $filter_rules                    = [ ],
  Array $filter_rules_v6                 = [ ],
  Array $nat_rules                       = [ ],
  Array $nat_rules_v6                    = [ ],
  Array $mangle_rules                    = [ ],
  Array $mangle_rules_v6                 = [ ],
  Array $allowall_interfaces             = [ ],
  Array $allowall_interfaces_v6          = [ ],
  Array $allow_tcp_ports                 = [ ],
  Array $allow_tcp_ports_v6              = [ ],
  Array $allow_udp_ports                 = [ ],
  Array $allow_udp_ports_v6              = [ ],
  Array $allow_ips                       = [ ],
  Array $allow_ips_v6                    = [ ],
  Boolean $ssh_safe_mode                 = true,
  Boolean $ssh_safe_mode_v6              = true,
  Enum['DROP','ACCEPT'] $default_input      = 'DROP',
  Enum['DROP','ACCEPT'] $default_input_v6   = 'DROP',
  Enum['DROP','ACCEPT'] $default_output     = 'ACCEPT',
  Enum['DROP','ACCEPT'] $default_output_v6  = 'ACCEPT',
  Enum['DROP','ACCEPT'] $default_forward    = 'ACCEPT',
  Enum['DROP','ACCEPT'] $default_forward_v6 = 'ACCEPT',
  Boolean $log_filter_defaults              = true,
  Boolean $manage_ipv6                      = true,
  Boolean $manage_firewalld                 = true,

  Boolean $preserve_rules_on_restore        = false,
  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    package { $package_name:
      ensure => present,
      before => Service[$service_name],
    }

    file { $config_file_path:
      ensure  => file,
      notify  => Service[$service_name],
      content => template($rules_template),
      mode    => '0640',
    }

    if $manage_ipv6 {
      if $service_name_v6 {
        service { $service_name_v6:
          ensure => running,
          enable => true,
        }
      }

      file { $config_file_path_v6:
        ensure  => file,
        notify  => Service[$service_name_v6],
        content => template($rules_template_v6),
        mode    => '0640',
      }
    }

    case $::osfamily {
      'RedHat': {
        if $manage_firewalld {
          service { 'firewalld':
            ensure => stopped,
            enable => false,
          }
        }
        $os_service_options = $preserve_rules_on_restore ? {
          true  => {
            start   => "/sbin/iptables-restore -n ${config_file_path}",
            restart => "/sbin/iptables-restore -n ${config_file_path}",
          },
          false => {},
        }
      }
      'Debian': {
        file { '/etc/iptables':
          ensure => directory,
        }
        $os_service_options = $preserve_rules_on_restore ? {
          true  => {
            start   => "/sbin/iptables-restore -n ${config_file_path}",
            restart => "/sbin/iptables-restore -n ${config_file_path}",
          },
          false => {},
        }
      }
      'Suse': {
        file { '/usr/lib/systemd/system/iptables.service':
          ensure  => file,
          content => template('psick/firewall/iptables.service.erb'),
          notify  => Service[$service_name],
        }
        file { '/etc/sysconfig/iptables.stop':
          ensure  => file,
          content => template('psick/firewall/iptables.stop.erb'),
          notify  => Service[$service_name],
        }
        package { 'SuSEfirewall2':
          ensure => absent,
        }
        $os_service_options = $preserve_rules_on_restore ? {
          true  => {
            restart => "/usr/sbin/iptables-restore -n ${config_file_path}",
          },
          false => {},
        }
      }
      default: {
        $os_service_options = {}
      }
    }

    $default_service_options = {
      ensure => running,
      enable => true,
    }

    service { $service_name:
      * => $default_service_options + $os_service_options,
    }

  }
}
