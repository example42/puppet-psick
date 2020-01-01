# Define psick::mariadb::query
#
define psick::mariadb::query (
  $query,
  $db             = undef,
  $user           = '',
  $password       = '',
  $host           = '',
  $query_filepath = '/root/puppet-mariadb'
  ) {

  if ! defined(File[$query_filepath]) {
    file { $query_filepath:
      ensure => directory,
    }
  }

  file { "mariadbquery-${name}.sql":
    ensure  => present,
    mode    => '0600',
    path    => "${query_filepath}/mariadbquery-${name}.sql",
    content => template('psick/mariadb/query.erb'),
    notify  => Exec["mariadbquery-${name}"],
  }

  $exec_flagfile = "${query_filepath}/mariadbquery-${name}.sql.done"

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

  if getvar('psick::mariadb::root_password') {
    $my_cnf = '--defaults-file=/root/.my.cnf'
  } else {
    $my_cnf = ''
  }

  exec { "remove_${exec_flagfile}":
    command     => "rm -f '${exec_flagfile}'",
    subscribe   => File["mariadbquery-${name}.sql"],
    path        => [ '/usr/bin' , '/usr/sbin' ],
    refreshonly => true,
    before      => Exec["mariadbquery-${name}"],
  }

  $exec_command = "mysql ${my_cnf} ${arg_user} ${arg_password} ${arg_host} < ${query_filepath}/mariadbquery-${name}.sql"

  exec { "mariadbquery-${name}":
    command   => "${exec_command} && touch ${exec_flagfile}",
    subscribe => File["mariadbquery-${name}.sql"],
    path      => [ '/usr/bin' , '/usr/sbin' ],
    creates   => $exec_flagfile,
  }

}
