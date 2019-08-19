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

  if getvar('psick::mysql::root_password') {
    $my_cnf = ''
  } else {
    $my_cnf = '--defaults-file=/root/.my.cnf'
  }
  exec { "mysqlquery-${name}":
    command     => "mysql ${my_cnf} \
                    ${arg_user} ${arg_password} ${arg_host} \
                    < ${query_filepath}/mysqlquery-${name}.sql",
    refreshonly => true,
    subscribe   => File["mysqlquery-${name}.sql"],
    path        => [ '/usr/bin' , '/usr/sbin' ],
  }

}
