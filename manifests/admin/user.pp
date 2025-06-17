# @summary Manage admin user
#
class psick::admin::user (
  Variant[Boolean,String] $ensure           = pick($psick::admin::ensure, 'present'),
  Optional[String]        $password         = undef,
  Boolean                 $configure_sudo   = true,
  String                  $sudo_template    = 'psick/admin/sudo.epp',

  Boolean                 $run_ssh_keygen   = true,

  Boolean             $manage               = $psick::manage,
  Boolean             $noop_manage          = $psick::noop_manage,
  Boolean             $noop_value           = $psick::noop_value,

) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    include psick::admin

    user { $psick::admin::user:
      ensure     => $ensure,
      comment    => 'Puppet managed admin user',
      managehome => true,
      shell      => '/bin/bash',
      home       => "/home/${psick::admin::user}",
      password   => $password,
    }

    $dir_ensure = ::tp::ensure2dir($ensure)

    file { "/home/${psick::admin::user}/.ssh" :
      ensure  => $dir_ensure,
      mode    => '0700',
      owner   => $psick::admin::user,
      group   => $psick::admin::group,
      require => User[$psick::admin::user],
    }

    if $run_ssh_keygen and $psick::admin::master_enable {
      psick::openssh::keygen { $psick::admin::user:
        require => File["/home/${$psick::admin::user}/.ssh"],
      }
      psick::puppet::set_external_fact { 'admin_user_key.sh':
        template => 'psick/admin/admin_user_key.sh.epp',
        mode     => '0755',
      }
    }

    if $configure_sudo {
      file { "/etc/sudoers.d/${psick::admin::user}" :
        ensure  => file,
        mode    => '0440',
        owner   => 'root',
        group   => 'root',
        content => $sudo_template,
      }
    }
  }
}
