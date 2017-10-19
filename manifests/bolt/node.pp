# @summary Manages bolt configurations on target nodes
#
class psick::bolt::node (

  Variant[Boolean,String] $ensure          = pick($::psick::bolt::ensure, 'present'),

) {

  include ::psick::bolt

  if $::psick::bolt::keyshare_method == 'storeconfigs' {
    @@sshkey { "bolt_${::fqdn}_rsa":
      ensure       => $ensure,
      host_aliases => [ $::fqdn, $::hostname, $::ipaddress ],
      type         => 'ssh-rsa',
      key          => $::sshrsakey,
      tag          => "bolt_node_${::psick::bolt::master}_rsa"
    }
    # Authorize master host ssh key for remote connection
    Ssh_authorized_key <<| tag == "bolt_master_${::psick::bolt::master}" |>>
  }
}
