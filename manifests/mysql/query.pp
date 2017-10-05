# Define psick::mysql::query
#
define psick::mysql::query (
  $query,
  $db             = undef,
  $user           = '',
  $password       = '',
  $host           = '',
  $query_filepath = '/root/puppet-mysql'
  ) {

  if ! defined(File[$query_filepath]) {
    file { $query_filepath:
      ensure => directory,
    }
  }

  file { "mysqlquery-${name}.sql":
    ensure  => present,
    mode    => '0600',
    path    => "${query_filepath}/mysqlquery-${name}.sql",
    content => template('psick/mysql/query.erb'),
    notify  => Exec["mysqlquery-${name}"],
  }


  $arg_user = $user ? {
    ''      => '',
    default => "-u ${user}",
  }

  $arg_host = $host ? {
  ''      => '',
  default => "-h ${host}",
  }

  $arg_password = $password ? {
    ''      => '',
    default => "--password=\"${password}\"",
  }

  $arg_defaults_file = $mysql::real_root_password ? {
    ''      => '',
    default => '--defaults-file=/root/.my.cnf',
  }

  exec { "mysqlquery-${name}":
    command     => "mysql ${arg_defaults_file} \
                    ${arg_user} ${arg_password} ${arg_host} \
                    < ${query_filepath}/mysqlquery-${name}.sql",
    refreshonly => true,
    subscribe   => File["mysqlquery-${name}.sql"],
    path        => [ '/usr/bin' , '/usr/sbin' ],
  }

}
