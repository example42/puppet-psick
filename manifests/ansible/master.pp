# @summary Manages Ansible configurations on Ansible master
#
class psick::ansible::master (

  Variant[Boolean,String] $ensure          = 'present',

  Variant[Undef,String]   $inventory_epp   = undef,

) {

  include ::psick::ansible

  if $::psick::ansible::keyshare_method == 'storeconfig' and $::psick::ansible::ssh_key {
    @@ssh_authorized_key { "ansible_user_${::psick::ansible::user_name}_rsa-${clientcert}":
      ensure => $ensure,
      key    => $::psick::ansible::ssh_key,
      user   => $::psick::ansible::user_name,
      type   => 'rsa',
      tag    => "ansible_master_${::psick::ansible::master}"
    }
    Sshkey <<| tag == "ansible_node_${::psick::ansible::master}_rsa" |>>
  }

}
