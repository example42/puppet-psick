# @summary Manages bolt configurations on node from where bolt tasks
# are inkoved
#
class psick::bolt::master (

  Variant[Boolean,String] $ensure        = 'present',

  # Management of bolt installation
  Boolean $install_package     = true,
  Boolean $install_system_gems = false,
  Boolean $install_puppet_gems = false,

  # Management of user running bolt
  Optional[String]        $user_password    = undef,
  Optional[String]        $user_home        = undef,
  Boolean                 $create_bolt_user = true,
  Boolean                 $run_ssh_keygen   = true,
  String                  $fact_template    = 'psick/bolt/bolt_user_key.sh.erb',

  # Management of automatic host list files used by bolt command
  Variant[Undef,String]   $inventory_epp = undef,
  Boolean $generate_nodes_list           = true,
  Hash $nodes_list_hash                  = {},

  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,

) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $dir_ensure = ::tp::ensure2dir($ensure)

    include ::psick::bolt

    # Bolt installation
    if $install_system_gems {
      if $::psick::bolt::auto_prereq {
        include ::psick::ruby
        include ::psick::ruby::buildgems
      }
      package { 'bolt':
        ensure   => $ensure,
        provider => 'gem',
        require  => [ Class['psick::ruby'],Class['psick::ruby::buildgems'] ],
      }
    }
    if $install_puppet_gems {
      package { 'bolt':
        ensure   => $ensure,
        provider => 'puppet_gem',
      }
    }

    if $install_package {
      package { 'bolt':
        ensure   => $ensure,
      }
    }

    # Management of the user running bolt
    $user_home_dir = $user_home ? {
      undef   => $::psick::bolt::bolt_user ? {
        root    => '/root',
        default => "/home/${::psick::bolt::bolt_user}",
      },
      default => $user_home
    }

    if $create_bolt_user {
      user { $::psick::bolt::bolt_user:
        ensure     => $ensure,
        comment    => 'Puppet managed bolt user',
        managehome => true,
        shell      => '/bin/bash',
        home       => $user_home_dir,
        password   => $user_password,
      }
    }

    $ssh_dir_require = $create_bolt_user ? {
      true  => User[$::psick::bolt::bolt_user],
      false => undef,
    }

    if $run_ssh_keygen or $::psick::bolt::bolt_user_pub_key {
      file { "${user_home_dir}/.ssh" :
        ensure  => $dir_ensure,
        mode    => '0700',
        owner   => $::psick::bolt::bolt_user,
        group   => $::psick::bolt::bolt_user,
        require => $ssh_dir_require,
      }
    }

    if $run_ssh_keygen {
      psick::openssh::keygen { $::psick::bolt::bolt_user:
        require => File["${user_home_dir}/.ssh"],
      }
      psick::puppet::set_external_fact { 'bolt_user_key.sh':
        template => $fact_template,
        mode     => '0755',
      }
    }

    if $::psick::bolt::keyshare_method == 'storeconfigs'
    and defined('psick::bolt::bolt_user_pub_key')
    or defined('bolt_user_key') {
      @@ssh_authorized_key { "bolt_user_${::psick::bolt::ssh_user}_rsa-${clientcert}":
        ensure => $ensure,
        key    => pick($::psick::bolt::bolt_user_pub_key,$::bolt_user_key),
        user   => $::psick::bolt::ssh_user,
        type   => 'rsa',
        tag    => "bolt_master_${::psick::bolt::master}_${::psick::bolt::bolt_user}"
      }
      Sshkey <<| tag == "bolt_node_${::psick::bolt::master}_rsa" |>>
    }

    if $::psick::bolt::bolt_user_pub_key and $::psick::bolt::bolt_user_priv_key {
      file { "${user_home_dir}/.ssh/id_rsa.pub":
        ensure  => $dir_ensure,
        mode    => '0700',
        owner   => $::psick::bolt::bolt_user,
        group   => $::psick::bolt::bolt_user,
        content => $::psick::bolt::bolt_user_pub_key,
      }
      file { "${user_home_dir}/.ssh/id_rsa":
        ensure  => $dir_ensure,
        mode    => '0700',
        owner   => $::psick::bolt::bolt_user,
        group   => $::psick::bolt::bolt_user,
        content => $::psick::bolt::bolt_user_priv_key,
      }
    }

    if $generate_nodes_list {
      $nodes_query = "nodes { certname ~ '.*' }"
      $nodes = puppetdb_query($nodes_query)
      $nodes_list = $nodes.map |$node| { $node['certname'] }
      $nodes_csv = join($nodes_list.sort,',')

      file { "${user_home_dir}/nodes":
        ensure => $dir_ensure,
        owner  => $::psick::bolt::bolt_user,
        group  => $::psick::bolt::bolt_user,
      }
      $default_file_options = {
        ensure => $ensure,
        owner  => $::psick::bolt::bolt_user,
        group  => $::psick::bolt::bolt_user,
      }
      $default_nodes_lists_hash = {
        'all' => {
          content => $nodes_csv,
        }
      }
      $full_nodes_list_hash = $default_nodes_lists_hash + $nodes_list_hash
      $full_nodes_list_hash.each | $k,$v | {
        file { "${user_home_dir}/nodes/${k}":
          * => $default_file_options + $v,
        }
      }
    }
  }
}
