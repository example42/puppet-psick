# This class manages network configurations using defines similar and
# compatible with example42-network module ones
# It's declare in psick::network if you set in Hiera:
#     psick::network::module: 'example42-network'
#
# @param bonding_mode Define bonding mode (default: active-backup)
# @param network_template The erb template to use, only on RedHad derivatives,
#                         for the file /etc/sysconfig/network
# @param routes Hash of routes to pass to ::network::mroute define
#               Note: This is not a real class parameter but a key looked up
#               via lookup('psick::network::routes', Hash, 'deep', {})
# @param interfaces Hash of interfaces to pass to ::network::interface define
#                   Note: This is not a real class parameter but a key looked up
#                   via lookup('psick::network::interfaces', Hash, 'deep', {})
#                   Note that this psick automatically adds some default
#                   options according to the interface type. You can override
#                   them in the provided hash
#
class psick::network::example42 (
  String $bonding_mode     = 'active-backup',
  String $network_template = 'psick/network/network.erb',
) {
  file { '/etc/modprobe.d/bonding.conf':
    ensure => file,
  }
  $routes = lookup('psick::network::routes', Hash, 'deep', {})
  $routes.each |$r,$o| {
    psick::network::route { $r:
      routes => $o[routes],
    }
  }
  $default_options = {
    onboot     => 'yes',
    'type'     => 'Ethernet',
    template   => "psick/network/interface-${facts['os']['family']}.erb",
    options    => {
      'IPV6INIT'           => 'no',
      'IPV4_FAILURE_FATAL' => 'yes',
    },
    bootproto  => 'none',
    nozeroconf => 'yes',
  }
  $default_bonding_options = {
    'type'         => 'Bond',
    bonding_opts   => "resend_igmp=1 updelay=30000 use_carrier=1 miimon=100 downdelay=100 xmit_hash_policy=0 primary_reselect=0 fail_over_mac=0 arp_validate=0 mode=${bonding_mode} arp_interval=0 ad_select=0",
    bonding_master => 'yes',
  }
  $interfaces = lookup('psick::network::interfaces', Hash, 'deep', {})
  $interfaces.each |$r,$o| {
    if $r =~ /^bond/ {
      $options = $default_options + $default_bonding_options + $o
      file_line { "bonding.conf ${r}":
        line    => "alias netdev-${r} bonding",
        path    => '/etc/modprobe.d/bonding.conf',
        require => File['/etc/modprobe.d/bonding.conf'],
      }
    } else {
      $options = $default_options + $o
    }
    psick::network::interface { $r:
      * => $options,
    }
  }

  if $facts['os']['family'] == 'RedHat'
  and $network_template != '' {
    file { '/etc/sysconfig/network':
      ensure  => file,
      content => template($network_template),
    }
  }
}
