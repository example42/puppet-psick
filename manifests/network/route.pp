# == Definition: psick::network::route
#
# Manages routes for an interface
# Configures /etc/sysconfig/networking-scripts/route-$name on Rhel
# Adds 2 files on Debian:
# One under /etc/network/if-up.d and
# One in /etc/network/if-down.d
#
# === Parameters:
#
# [*routes*]
#   Required parameter. Must be an hash of network-gateway pairs.
#   Example:
#   psick::network::route { 'bond1':
#     routes => {
#       '99.99.228.0/24'   => 'bond1',
#       '100.100.244.0/22' => '174.136.107.1',
#     }
#
# === Actions:
#
# On Rhel
# Deploys the file /etc/sysconfig/network-scripts/route-$name.
#
# On Debian
# Deploy 2 files 1 under /etc/network/if-up.d and 1 in /etc/network/if-down.d
#
# On Suse
# Deploys the file /etc/sysconfig/network/ifroute-$name.
#
define psick::network::route (
  Hash $routes,
  Integer $interface = $title,
  $ensure            = 'present'
) {

  $real_config_file_notify = $config_file_notify ? {
    'class_default' => $::network::manage_config_file_notify,
    default         => $config_file_notify,
  }

  case $::osfamily {
    'RedHat': {
      file { "route-${interface}":
        ensure  => $ensure,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        path    => "/etc/sysconfig/network-scripts/route-${interface}",
        content => template('psick/network/route-RedHat.erb'),
        notify  => $route_notify,
      }
    }
    'Debian': {
      file { "routeup-${interface}":
        ensure  => $ensure,
        mode    => '0755',
        owner   => 'root',
        group   => 'root',
        path    => "/etc/network/if-up.d/z90-route-${interface}",
        content => template('psick/network/route_up-Debian.erb'),
        notify  => $route_notify,
      }
      file { "routedown-${interface}":
        ensure  => $ensure,
        mode    => '0755',
        owner   => 'root',
        group   => 'root',
        path    => "/etc/network/if-down.d/z90-route-${interface}",
        content => template('psick/network/route_down-Debian.erb'),
        notify  => $route_notify,
      }
    }
    'SuSE': {
      file { "route-${interface}":
        ensure  => $ensure,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        path    => "/etc/sysconfig/network/ifroute-${interface}",
        content => template('psick/network/route-SuSE.erb'),
        notify  => $route_notify,
      }
    }
    default: { fail('Operating system not supported')  }
  }
}
