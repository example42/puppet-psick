# @summary Manages Ansible configurations on Ansible master
#
class psick::ansible::master (

  Variant[Boolean,String] $ensure        = 'present',

  Variant[Undef,String]   $inventory_epp = undef,
  Variant[Undef,String]   $ssh_key       = undef,

  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    include ::psick::ansible

    if $::psick::ansible::keyshare_method == 'storeconfigs'
    and ($ssh_key or $::ansible_user_key) {
      @@ssh_authorized_key { "ansible_user_${::psick::ansible::user_name}_rsa-${clientcert}":
        ensure => $ensure,
        key    => pick($ssh_key,$::ansible_user_key),
        user   => $::psick::ansible::user_name,
        type   => 'rsa',
        tag    => "ansible_master_${::psick::ansible::master}"
      }
      Sshkey <<| tag == "ansible_node_${::psick::ansible::master}_rsa" |>>
    }
  }

}
