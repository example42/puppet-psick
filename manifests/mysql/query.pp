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
  }

  $exec_flagfile = "${query_filepath}/mysqlquery-${name}.sql.done"

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
    $my_cnf = '--defaults-file=/root/.my.cnf'
  } else {
    $my_cnf = ''
  }

  exec { "remove_${exec_flagfile}":
    command     => "rm -f '${exec_flagfile}'",
    subscribe   => File["mysqlquery-${name}.sql"],
    path        => [ '/usr/bin' , '/usr/sbin' ],
    refreshonly => true,
    before      => Exec["mysqlquery-${name}"],
  }

  $exec_command = "mysql ${my_cnf} ${arg_user} ${arg_password} ${arg_host} < ${query_filepath}/mysqlquery-${name}.sql"

  exec { "mysqlquery-${name}":
    command   => "${exec_command} && touch ${exec_flagfile}",
    subscribe => File["mysqlquery-${name}.sql"],
    path      => [ '/usr/bin' , '/usr/sbin' ],
    creates   => $exec_flagfile,
  }

}
