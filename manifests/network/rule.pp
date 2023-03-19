# === Parameters:
#
#   $iprule - required
#
# === Actions:
#
# On RHEL
# Deploys /etc/sysconfig/networking-scripts/rule-$name and /etc/sysconfig/networking-scripts/rule6-$name
#
# On Debian
# Deploys 2 files, 1 under /etc/network/if-up.d and 1 in /etc/network/if-down.d
#
# === Sample Usage:
#
#   psick::network::rule { 'eth0':
#     iprule => ['from 192.168.22.0/24 lookup vlan22', ],
#   }
#
# === Authors:
#
# Marcus Furlong <furlongm@gmail.com>
#
define psick::network::rule (
  Array $iprule,
  String $interface                = $name,
  Optional[Array] $family          = undef,
  Enum['present','absent'] $ensure = 'present',
) {
  include psick::network

  case $::osfamily {
    'RedHat': {
      file { "rule-${interface}":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        path    => "/etc/sysconfig/network-scripts/rule-${interface}",
        content => template('psick/network/rule-RedHat.erb'),
        notify  => $psick::network::manage_config_file_notify,
      }
      file { "rule6-${interface}":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        path    => "/etc/sysconfig/network-scripts/rule6-${interface}",
        content => template('psick/network/rule6-RedHat.erb'),
        notify  => $psick::network::manage_config_file_notify,
      }
    }
    'Suse': {
      file { "ifrule-${interface}":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        path    => "/etc/sysconfig/network/ifrule-${interface}",
        content => template('psick/network/rule-RedHat.erb'),
        notify  => $psick::network::manage_config_file_notify,
      }
    }
    'Debian': {
      file { "ruleup-${name}":
        ensure  => $ensure,
        mode    => '0755',
        owner   => 'root',
        group   => 'root',
        path    => "/etc/network/if-up.d/z90-rule-${name}",
        content => template('psick/network/rule_up-Debian.erb'),
        notify  => $psick::network::manage_config_file_notify,
      }
      file { "ruledown-${name}":
        ensure  => $ensure,
        mode    => '0755',
        owner   => 'root',
        group   => 'root',
        path    => "/etc/network/if-down.d/z90-rule-${name}",
        content => template('psick/network/rule_down-Debian.erb'),
        notify  => $psick::network::manage_config_file_notify,
      }
    }
    default: { fail('Operating system not supported') }
  }
} # define network::rule
