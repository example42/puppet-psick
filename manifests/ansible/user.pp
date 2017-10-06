# @summary Manage ansible user
#
class psick::ansible::user (
  Variant[Boolean,String] $ensure           = pick($::psick::ansible::ensure, 'present'),
  Optional[String]        $password         = undef,
  Boolean                 $configure_sudo   = true,
  Boolean                 $run_ssh_keygen   = false,
) {

  include ::psick::ansible

  user { $::psick::ansible::user_name:
    ensure     => $ensure,
    comment    => 'Puppet managed ansible user',
    managehome => true,
    shell      => '/bin/bash',
    home       => "/home/${::psick::ansible::user_name}",
    password   => $password,
  }

  $dir_ensure = ::tp::ensure2dir($ensure)

  file { "/home/${::psick::ansible::user_name}/.ssh" :
    ensure  => $dir_ensure,
    mode    => '0700',
    owner   => $::psick::ansible::user_name,
    group   => $::psick::ansible::user_name,
    require => User[$::psick::ansible::user_name],
  }

  if $run_ssh_keygen {
    psick::openssh::keygen { $::psick::ansible::user_name:
      require => File["/home/${::psick::ansible::user_name}/.ssh"],
    }
  }

  if $configure_sudo {
    file { "/etc/sudoers.d/${::psick::ansible::user_name}" :
      ensure  => file,
      mode    => '0440',
      owner   => 'root',
      group   => 'root',
      content => "${::psick::ansible::user_name} ALL = NOPASSWD : ALL\n",
    }
  }

}
