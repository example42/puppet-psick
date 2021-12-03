# @summary This define installs node vi nvm
#
# A description of what this class does
#
define psick::nodejs::nvm (
  Boolean $nvm_manage           = true,
  String $user                  = $title,

  Hash $node_instances          = { },
  String $node_instance_default = '8.12.0',

  Hash $npm_packages            = {},

  String $install_script_url = 'https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh',
) {
  $nvm_target = $user ? {
    'root'  => '/root',
    default => "/home/${user}",
  }

  # NVM  management
  if $nvm_manage {
    archive { "${nvm_target}/nvm_install.sh":
      source        => $install_script_url,
      extract       => false,
      checksum_type => 'none',
      cleanup       => false,
      user          => $user,
      group         => $user,
      before        => File["${nvm_target}/nvm_install.sh"],
    }
    file { "${nvm_target}/nvm_install.sh":
      mode   => '0777',
      owner  => $user,
      group  => $user,
      before => Exec["nvm_installation for ${title}"],
    }
    file { "${nvm_target}/.nvm":
      ensure => directory,
      owner  => $user,
      group  => $user,
      before => Exec["nvm_installation for ${title}"],
    }
    exec { "nvm_installation for ${title}":
      command     => "${nvm_target}/nvm_install.sh",
      cwd         => $nvm_target,
      user        => $user,
      path        => $facts['path'],
      creates     => "${nvm_target}/.nvm/nvm.sh",
      environment => [ "NVM_DIR=${nvm_target}/.nvm" ],
      provider    => shell,
    }
    file { "${nvm_target}/npm":
      ensure => link,
      owner  => $user,
      group  => $user,
      target => "${nvm_target}/.nvm/versions/node/v${node_instance_default}",
    }
  }

  if $node_instance_default {
    psick::nodejs::install { $node_instance_default:
      user        => $user,
      set_default => true,
      require     => Exec["nvm_installation for ${title}"],
    }
  }

  $node_instances.each |$k,$v| {
    psick::nodejs::install { $k:
      user    => $user,
      require => Exec["nvm_installation for ${title}"],
      *       => $v,
    }
  }

  $npm_defaults = {
    user    => $user,
    require => File["${nvm_target}/npm"],
  }
  $npm_packages.each | $k,$v | {
    psick::nodejs::npm { $k:
      * => $npm_defaults + $v,
    }
  }
}
