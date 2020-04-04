# @summary Manages Ansible configurations on nodes
#
class psick::ansible::node (

  Variant[Boolean,String] $ensure          = pick($::psick::ansible::ensure, 'present'),
  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    include ::psick::ansible

    if $::psick::ansible::keyshare_method == 'storeconfigs' {
      @@sshkey { "ansible_${::fqdn}_rsa":
        ensure       => $ensure,
        host_aliases => [ $::fqdn, $::hostname, $::ipaddress ],
        type         => 'ssh-rsa',
        key          => $::sshrsakey,
        tag          => "ansible_node_${::psick::ansible::master}_rsa"
      }
      # Authorize master host ssh key for remote connection
      Ssh_authorized_key <<| tag == "ansible_master_${::psick::ansible::master}" |>>
    }
  }
}
