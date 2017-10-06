# Define psick::mariadb::user
#
define psick::mariadb::user (
  $user           = $title,
  $password       = '',
  $password_hash  = '',
  $host           = 'localhost',
  $grant_filepath = '/root/puppet-mariadb'
  ) {

  if (!defined(File[$grant_filepath])) {
    file {$grant_filepath:
      ensure => directory,
      path   => $grant_filepath,
      mode   => '0700',
    }
  }

  $nice_host = regsubst($host, '/', '_')
  $grant_file = "mariadbuser-${user}-${nice_host}.sql"

  file { $grant_file:
    ensure  => present,
    mode    => '0600',
    path    => "${grant_filepath}/${grant_file}",
    content => template('psick/mariadb/user.erb'),
  }

  exec { "mariadbuser-${user}-${nice_host}":
    command     => "mysql --defaults-file=/root/.my.cnf -uroot < ${grant_filepath}/${grant_file}",
    subscribe   => File[$grant_file],
    path        => [ '/usr/bin' , '/usr/sbin' ],
    refreshonly => true,
  }

}
