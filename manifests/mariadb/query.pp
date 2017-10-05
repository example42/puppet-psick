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

  exec { "mariadbquery-${name}":
    command     => "mysql ${arg_defaults_file} \
                    ${arg_user} ${arg_password} ${arg_host} \
                    < ${query_filepath}/mariadbquery-${name}.sql",
    refreshonly => true,
    subscribe   => File["mariadbquery-${name}.sql"],
    path        => [ '/usr/bin' , '/usr/sbin' ],
  }

}
