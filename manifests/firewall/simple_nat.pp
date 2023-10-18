# Simple psick to manage a NAT server that allow full
# access from the specified $source_net.
#
# This psick needs the following modules:
# example42/sysctl
# puppetlabs/firewall
#
class psick::firewall::simple_nat (
  String $source_net = "${facts['networking']['network']}/${facts['networking']['netmask']}",
  Boolean          $manage               = $psick::manage,
  Boolean          $noop_manage          = $psick::noop_manage,
  Boolean          $noop_value           = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    psick::sysctl::set { 'net/ipv4/ip_forward': value => '1' }
    firewall { "100 snat for network ${source_net}":
      chain  => 'POSTROUTING',
      jump   => 'MASQUERADE',
      proto  => 'all',
      source => $source_net,
      table  => 'nat',
    }
    firewall { "100 forward for network ${source_net}":
      chain  => 'FORWARD',
      jump   => 'ACCEPT',
      proto  => 'all',
      source => $source_net,
    }
  }
}
