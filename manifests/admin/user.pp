# @summary Manage admin user
#
class psick::admin::user (
  Variant[Boolean,String] $ensure           = pick($::psick::admin::ensure, 'present'),
  Optional[String]        $password         = undef,
  Boolean                 $configure_sudo   = true,
  Boolean                 $run_ssh_keygen   = true,

  Boolean             $manage               = $::psick::manage,
  Boolean             $noop_manage          = $::psick::noop_manage,
  Boolean             $noop_value           = $::psick::noop_value,

) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    include ::psick::admin

    user { $::psick::admin::user_name:
      ensure     => $ensure,
      comment    => 'Puppet managed admin user',
      managehome => true,
      shell      => '/bin/bash',
      home       => "/home/${::psick::admin::user_name}",
      password   => $password,
    }

    $dir_ensure = ::tp::ensure2dir($ensure)

    file { "/home/${::psick::admin::user_name}/.ssh" :
      ensure  => $dir_ensure,
      mode    => '0700',
      owner   => $::psick::admin::user_name,
      group   => $::psick::admin::user_name,
      require => User[$::psick::admin::user_name],
    }

    if $run_ssh_keygen and $::psick::admin::master_enable {
      psick::openssh::keygen { $::psick::admin::user_name:
        require => File["/home/${::psick::admin::user_name}/.ssh"],
      }
      psick::puppet::set_external_fact { 'admin_user_key.sh':
        template => 'psick/admin/admin_user_key.sh.erb',
        mode     => '0755',
      }
    }

    if $configure_sudo {
      file { "/etc/sudoers.d/${::psick::admin::user_name}" :
        ensure  => file,
        mode    => '0440',
        owner   => 'root',
        group   => 'root',
        content => "${::psick::admin::user_name} ALL = NOPASSWD : ALL\n",
      }
    }
  }
}
