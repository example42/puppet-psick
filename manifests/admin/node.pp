# @summary Manages admin configurations on nodes
#
class psick::admin::node (

  Variant[Boolean,String] $ensure        = pick($::psick::admin::ensure, 'present'),
  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    include ::psick::admin

    if $::psick::admin::keyshare_method == 'storeconfigs' {
      @@sshkey { "admin_${::fqdn}_rsa":
        ensure       => $ensure,
        host_aliases => [ $::fqdn, $::hostname, $::ipaddress ],
        type         => 'ssh-rsa',
        key          => $::sshrsakey,
        tag          => "admin_node_${::psick::admin::master}_rsa"
      }
      # Authorize master host ssh key for remote connection
      Ssh_authorized_key <<| tag == "admin_master_${::psick::admin::master}" |>>
    }
  }
}
