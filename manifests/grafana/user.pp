# This define manages Grafana users via the http api
#
# @param ensure To install or remove a user
#
define psick::grafana::user (
  Enum['present','absent'] $ensure = 'present',
  String $user                     = $title,
  String $password                 = $title,
  String $admin_user               = 'admin',
  String $admin_password           = 'admin',
  String $host                     = 'localhost',
  String $email                    = 'root@localhost',
  Integer $port                    = 3000,
  Enum['http','https'] $protocol   = 'http',
  Optional[String] $exec_require   = 'Service[grafana-server]',
  StdLib::Absolutepath $user_dir_path = '/root/puppet-grafana',
) {

  if (!defined(File[$user_dir_path])) {
    file { $user_dir_path:
      ensure => directory,
      mode   => '0700',
      owner  => 'root',
    }
  }

  file { "${user_dir_path}/${user}_${host}":
    notify  => Exec["grafana user add ${title}"],
    mode    => '0750',
    owner   => 'root',
    content => template('psick/grafana/user.erb')
  }
  exec { "grafana user add ${title}":
    command     => "${user_dir_path}/${user}_${host}",
    require     => $exec_require,
    path        => $::path,
    refreshonly => true,
  }
}
