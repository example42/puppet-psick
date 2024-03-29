# This class manages an host hostname
# It supports hostname preservation on cloud instances by
# setting update_cloud_cfg to true (Needs cloud-init installed)
#
class psick::hostname (
  String                $host                 = $facts['networking']['hostname'],
  Variant[Undef,String] $fqdn                 = $facts['networking']['fqdn'],
  Variant[Undef,String] $dom                  = $facts['networking']['domain'],
  String                $ip                   = $facts['networking']['ip'],
  Boolean               $update_hostname      = true,
  Boolean               $update_host_entry    = true,
  Boolean               $update_network_entry = true,
  Boolean               $update_cloud_cfg     = false,

  Boolean               $manage               = $psick::manage,
  Boolean               $noop_manage          = $psick::noop_manage,
  Boolean               $noop_value           = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    case $facts['kernel'] {
      'Linux': {
        if $facts['virtual'] != 'docker' {
          if $update_hostname {
            file { '/etc/hostname':
              ensure  => file,
              owner   => 'root',
              group   => 'root',
              mode    => '0644',
              content => "${facts['networking']['fqdn']}\n",
              notify  => Exec['apply_hostname'],
            }

            exec { 'apply_hostname':
              command => '/bin/hostname -F /etc/hostname',
              unless  => '/usr/bin/test `hostname` = `/bin/cat /etc/hostname`',
            }
          }

          if $update_host_entry {
            host { $host:
              ensure       => present,
              host_aliases => $facts['networking']['fqdn'],
              ip           => $ip,
            }
          }

          if $update_network_entry {
            case $facts['os']['family'] {
              'RedHat': {
                file { '/etc/sysconfig/network':
                  ensure  => file,
                  content => "NETWORKING=yes\nNETWORKING_IPV6=no\nHOSTNAME=${fqdn}\n",
                  notify  => Exec['apply_hostname'],
                }
              }
              default: {}
            }
          }

          if $update_cloud_cfg {
            file { '/etc/cloud/cloud.cfg.d/99_preserve_hostname.cfg':
              ensure  => file,
              content => "preserve_hostname: true\n",
              notify  => Exec['apply_hostname'],
            }
          }
        }
      }
      'windows': {
        if $update_hostname {
          exec { 'Change win hostname':
            command  => "netdom renamecomputer ${facts['networking']['hostname']} /newname:${host} /force",
            unless   => "hostname | findstr /I /B /C:'${host}'",
            provider => powershell,
          }
        }
      }
      default: {
        notice("psick::hostname does not support ${facts['kernel']}")
      }
    }
  }
}
