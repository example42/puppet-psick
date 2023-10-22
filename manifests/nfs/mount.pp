# Derived from https://github.com/example42/puppet-nfs/blob/master/manifests/mount.pp
#
define psick::nfs::mount (
  String $server,
  String $share,
  Enum[present,absent] $ensure = present,
  String $mountpoint = '', # lint:ignore:params_empty_string_assignment
  String $client_options = 'auto',
) {
  $real_mountpoint = $mountpoint ? {
    ''      => $name,
    default => $mountpoint
  }

  mount { "shared ${share} by ${server}":
    device   => "${server}:${share}",
    fstype   => 'nfs',
    name     => $real_mountpoint,
    options  => $client_options,
    remounts => false,
    atboot   => true,
  }

  case $ensure {
    'present': {
      exec { "create ${real_mountpoint} and parents":
        command => "mkdir -p ${real_mountpoint}",
        unless  => "test -d ${real_mountpoint}",
        path    => '/bin:/usr/bin:/usr/local/bin',
      }
      Mount["shared ${share} by ${server}"] {
        require => [Exec["create ${real_mountpoint} and parents"]],
        ensure  => mounted,
      }
    }

    'absent': {
      Mount["shared ${share} by ${server}"] {
        ensure => unmounted,
      }
    }

    default: {}
  }
}
