# Define psick::mysql::user
#
define psick::mysql::user (
  $user           = $title,
  $password       = '',
  $password_hash  = '',
  $host           = 'localhost',
  $grant_filepath = '/root/puppet-mysql'
  ) {

  if (!defined(File[$grant_filepath])) {
    file {$grant_filepath:
      ensure => directory,
      path   => $grant_filepath,
      mode   => '0700',
    }
  }

  $nice_host = regsubst($host, '/', '_')
  $grant_file = "mysqluser-${user}-${nice_host}.sql"

  file { $grant_file:
    ensure  => present,
    mode    => '0600',
    path    => "${grant_filepath}/${grant_file}",
    content => template('psick/mysql/user.erb'),
  }

  exec { "mysqluser-${user}-${nice_host}":
    command     => "mysql --defaults-file=/root/.my.cnf -uroot < ${grant_filepath}/${grant_file}",
    subscribe   => File[$grant_file],
    path        => [ '/usr/bin' , '/usr/sbin' ],
    refreshonly => true,
  }

}
