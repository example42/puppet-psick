# @summary Manages bolt configurations on target nodes
#
class psick::bolt::node (
  Variant[Boolean,String] $ensure          = pick($psick::bolt::ensure, 'present'),
  Optional[String]        $user_password   = undef,
  Optional[String]        $user_home       = undef,
  Boolean                 $create_ssh_user = true,
  Boolean                 $configure_sudo  = true,
  String                  $sudo_template   = 'psick/bolt/user/sudo.erb',

  Boolean                 $manage_host_key = $psick::bolt::manage_host_key,
  Boolean                 $manage_ssh_dir  = true,

  Boolean            $manage               = $psick::manage,
  Boolean            $noop_manage          = $psick::noop_manage,
  Boolean            $noop_value           = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $dir_ensure = ::tp::ensure2dir($ensure)

    include psick::bolt

    $user_home_dir = $user_home ? {
      undef   => $psick::bolt::ssh_user ? {
        'root'    => '/root',
        default => "/home/${psick::bolt::ssh_user}",
      },
      default => $user_home
    }

    if $create_ssh_user {
      user { $psick::bolt::ssh_user:
        ensure     => $ensure,
        comment    => 'Puppet managed user for bolt access',
        managehome => true,
        shell      => '/bin/bash',
        home       => $user_home_dir,
        password   => $user_password,
      }

      if $manage_ssh_dir {
        file { "${user_home_dir}/.ssh" :
          ensure  => $dir_ensure,
          mode    => '0700',
          owner   => $psick::bolt::ssh_user,
          group   => $psick::bolt::ssh_group,
          require => User[$psick::bolt::ssh_user],
        }
      }
    }

    if $configure_sudo {
      file { "/etc/sudoers.d/${psick::bolt::ssh_user}" :
        ensure  => file,
        mode    => '0440',
        owner   => 'root',
        group   => 'root',
        content => template($sudo_template),
      }
    }

    if $psick::bolt::keyshare_method == 'storeconfigs' {
      if $manage_host_key {
        @@sshkey { "bolt_${facts['networking']['fqdn']}_rsa":
          ensure       => $ensure,
          host_aliases => [$facts['networking']['fqdn'], $facts['networking']['hostname'], $facts['networking']['ip']],
          type         => 'ssh-rsa',
          key          => $facts['ssh']['rsa']['key'],
          tag          => "bolt_node_${psick::bolt::master}_rsa",
        }
      }
      # Authorize master host bolt user ssh key for remote connection
      Ssh_authorized_key <<| tag == "bolt_master_${psick::bolt::master}_${psick::bolt::bolt_user}" |>>
    }
    if $psick::bolt::keyshare_method == 'static' {
      ssh_authorized_key { "bolt_user_${psick::bolt::ssh_user}_rsa-${psick::bolt::master}":
        ensure  => $ensure,
        key     => $psick::bolt::bolt_user_pub_key,
        user    => $psick::bolt::ssh_user,
        type    => $psick::bolt::ssh_key_type,
        options => $psick::bolt::ssh_auth_key_options,
      }
    }
  }
}
