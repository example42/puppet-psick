# @summary Manages admin configurations on nodes
#
class psick::admin::node (

  Variant[Boolean,String] $ensure        = pick($psick::admin::ensure, 'present'),
  Boolean          $manage               = $psick::manage,
  Boolean          $noop_manage          = $psick::noop_manage,
  Boolean          $noop_value           = $psick::noop_value,
  Boolean          $manage_host_key      = $psick::admin::manage_host_key,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    include psick::admin

    if $psick::admin::keyshare_method == 'storeconfigs' {
      if $manage_host_key {
        @@sshkey { "admin_${facts['networking']['fqdn']}_rsa":
          ensure       => $ensure,
          host_aliases => [$facts['networking']['fqdn'], $facts['networking']['hostname'], $facts['networking']['ip']],
          type         => 'ssh-rsa',
          key          => $facts['ssh']['rsa']['key'],
          tag          => "admin_node_${psick::admin::master}_rsa",
        }
      }
      # Authorize master host ssh key for remote connection
      Ssh_authorized_key <<| tag == "admin_master_${psick::admin::master}" |>>
    }
  }
}
