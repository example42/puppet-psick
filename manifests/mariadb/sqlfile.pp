# Define psick::mariadb::sqlfile
#
define psick::mariadb::sqlfile (
  $file,
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

  $arg_defaults_file = $mariadb::real_root_password ? {
    ''      => '',
    default => '--defaults-file=/root/.my.cnf',
  }

  exec { "mariadbqueryfile-${name}":
    command => "mysql ${arg_defaults_file} ${arg_user} ${arg_password} ${arg_host} ${db} < ${file} && touch ${query_filepath}/mariadbqueryfile-${name}.run",
    path    => [ '/usr/bin' , '/usr/sbin' , '/bin' , '/sbin' ],
    creates => "${query_filepath}/mariadbqueryfile-${name}.run",
    unless  => "ls ${query_filepath}/mariadbqueryfile-${name}.run",
  }

}
