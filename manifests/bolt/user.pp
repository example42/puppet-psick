# @summary Manage bolt user
#
class psick::bolt::user (
  Variant[Boolean,String] $ensure           = pick($::psick::bolt::ensure, 'present'),
  Optional[String]        $password         = undef,
  Boolean                 $configure_sudo   = true,
  Boolean                 $run_ssh_keygen   = true,
  String                  $sudo_template    = 'psick/bolt/user/sudo.erb',
  String                  $fact_template    = 'psick/bolt/bolt_user_key.sh.erb',
  Optional[String]        $home_dir         = undef,
) {

  include ::psick::bolt

  $user_home_dir = $home_dir ? {
    undef   => $::psick::bolt::user_name ? {
      root    => '/root',
      default => "/home/${::psick::bolt::user_name}", 
    },
    default => $home_dir
  }

  user { $::psick::bolt::user_name:
    ensure     => $ensure,
    comment    => 'Puppet managed bolt user',
    managehome => true,
    shell      => '/bin/bash',
    home       => $user_home_dir,
    password   => $password,
  }

  $dir_ensure = ::tp::ensure2dir($ensure)

  file { "${user_home_dir}/.ssh" :
    ensure  => $dir_ensure,
    mode    => '0700',
    owner   => $::psick::bolt::user_name,
    group   => $::psick::bolt::user_name,
    require => User[$::psick::bolt::user_name],
  }

  if $run_ssh_keygen and $::psick::bolt::is_master {
    psick::openssh::keygen { $::psick::bolt::user_name:
      require => File["${user_home_dir}/.ssh"],
    }
    psick::puppet::set_external_fact { 'bolt_user_key.sh':
      template => $fact_template,
      mode     => '0755',
    }
  }

  if $configure_sudo {
    file { "/etc/sudoers.d/${::psick::bolt::user_name}" :
      ensure  => file,
      mode    => '0440',
      owner   => 'root',
      group   => 'root',
      content => template($sudo_template),
    }
  }

}
