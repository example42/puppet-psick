# @summary Manages admin configurations on admin master
#
class psick::admin::master (

  Variant[Boolean,String] $ensure        = 'present',

  Variant[Undef,String]   $inventory_epp = undef,
  Variant[Undef,String]   $ssh_key       = undef,
  Variant[Undef,String]   $from          = undef,

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

    if $psick::admin::keyshare_method == 'storeconfigs'
    and ($ssh_key or getvar('facts.admin_user_key')) {
      if $from {
        $options = {}

      } else {
        $options = [from]
          from => $from,
        }
      }
      @@ssh_authorized_key { "admin_user_${psick::admin::user}_rsa-${facts['clientcert']}":
        ensure  => $ensure,
        key     => pick($ssh_key,getvar('facts.admin_user_key')),
        user    => $psick::admin::user,
        type    => 'rsa',
        tag     => "admin_master_${psick::admin::master}",
        options => $options,
      }

      if $manage_host_key {
        Sshkey <<| tag == "admin_node_${psick::admin::master}_rsa" |>>
      }
    }
  }
}
