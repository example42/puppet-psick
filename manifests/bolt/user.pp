# @summary Manage bolt user
#
class psick::bolt::user (
  Variant[Boolean,String] $ensure           = pick($::psick::bolt::ensure, 'present'),
  Optional[String]        $password         = undef,
  Boolean                 $configure_sudo   = true,
  Boolean                 $run_ssh_keygen   = true,
) {

  include ::psick::bolt

  user { $::psick::bolt::user_name:
    ensure     => $ensure,
    comment    => 'Puppet managed bolt user',
    managehome => true,
    shell      => '/bin/bash',
    home       => "/home/${::psick::bolt::user_name}",
    password   => $password,
  }

  $dir_ensure = ::tp::ensure2dir($ensure)

  file { "/home/${::psick::bolt::user_name}/.ssh" :
    ensure  => $dir_ensure,
    mode    => '0700',
    owner   => $::psick::bolt::user_name,
    group   => $::psick::bolt::user_name,
    require => User[$::psick::bolt::user_name],
  }

  if $run_ssh_keygen and $::psick::bolt::is_master {
    psick::openssh::keygen { $::psick::bolt::user_name:
      require => File["/home/${::psick::bolt::user_name}/.ssh"],
    }
    psick::puppet::set_external_fact { 'bolt_user_key.sh':
      template => 'psick/bolt/bolt_user_key.sh.erb',
      mode     => '0755',
    }
  }

  if $configure_sudo {
    file { "/etc/sudoers.d/${::psick::bolt::user_name}" :
      ensure  => file,
      mode    => '0440',
      owner   => 'root',
      group   => 'root',
      content => "${::psick::bolt::user_name} ALL = NOPASSWD : ALL\n",
    }
  }

}
