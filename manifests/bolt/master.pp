# @summary Manages bolt configurations on node from where bolt tasks
# are inkoved
#
class psick::bolt::master (

  Variant[Boolean,String] $ensure        = 'present',

  Variant[Undef,String]   $inventory_epp = undef,
  Variant[Undef,String]   $ssh_key       = undef,

  Boolean $generate_nodes_list           = true,
  Hash $nodes_list_hash                  = {},           

) {

  include ::psick::bolt

  if $::psick::bolt::keyshare_method == 'storeconfigs'
  and ($ssh_key or $::bolt_user_key) {
    @@ssh_authorized_key { "bolt_user_${::psick::bolt::user_name}_rsa-${clientcert}":
      ensure => $ensure,
      key    => pick($ssh_key,$::bolt_user_key),
      user   => $::psick::bolt::user_name,
      type   => 'rsa',
      tag    => "bolt_master_${::psick::bolt::master}"
    }
    Sshkey <<| tag == "bolt_node_${::psick::bolt::master}_rsa" |>>
  }

  if $generate_nodes_list {
    $nodes_query = "nodes { certname ~ '.*' }"
    $nodes = puppetdb_query($nodes_query)
    $nodes_list = $nodes.map |$node| { $node['certname'] }
    $nodes_csv = join($nodes_list.sort,',') 

    $dir_ensure = ::tp::ensure2dir($ensure)
    file { "/home/${::psick::bolt::user_name}/nodes":
      ensure => $dir_ensure,
      owner  => $::psick::bolt::user_name,
      group  => $::psick::bolt::user_name,
    }
    $default_file_options = {
      ensure => $ensure,
      owner  => $::psick::bolt::user_name,
      group  => $::psick::bolt::user_name,
    }
    $default_nodes_lists_hash = {
      'all' => {
        content => $nodes_csv,
      }
    }
    $full_nodes_list_hash = $default_nodes_lists_hash + $nodes_list_hash
    $full_nodes_list_hash.each | $k,$v | {
      file { "/home/${::psick::bolt::user_name}/nodes/$k":
        * => $default_file_options + $v,
      }
    }
  }
}
