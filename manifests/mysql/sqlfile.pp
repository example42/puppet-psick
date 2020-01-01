# Define psick::mysql::sqlfile
#
define psick::mysql::sqlfile (
  $file,
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
  exec { "mysqlqueryfile-${name}":
    command => "mysql ${my_cnf} ${arg_user} ${arg_password} ${arg_host} ${db} < ${file} && touch ${query_filepath}/mysqlqueryfile-${name}.run", # lint:ignore:140chars
    path    => [ '/usr/bin' , '/usr/sbin' , '/bin' , '/sbin' ],
    creates => "${query_filepath}/mysqlqueryfile-${name}.run",
    unless  => "ls ${query_filepath}/mysqlqueryfile-${name}.run",
  }

}
