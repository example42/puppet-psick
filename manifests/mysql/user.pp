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
  $exec_flagfile = "${grant_filepath}/${grant_file}.done"

  file { $grant_file:
    ensure  => present,
    mode    => '0600',
    path    => "${grant_filepath}/${grant_file}",
    content => template('psick/mysql/user.erb'),
  }

  if getvar('psick::mysql::root_password') {
    $my_cnf = '--defaults-file=/root/.my.cnf'
  } else {
    $my_cnf = ''
  }

  exec { "remove_${exec_flagfile}":
    command     => "rm -f '${exec_flagfile}'",
    subscribe   => File[$grant_file],
    path        => [ '/usr/bin' , '/usr/sbin' ],
    refreshonly => true,
    before      => Exec["mysqluser-${user}-${nice_host}"],
  }
  exec { "mysqluser-${user}-${nice_host}":
    command   => "mysql ${my_cnf} -uroot < ${grant_filepath}/${grant_file} && touch ${exec_flagfile}",
    subscribe => File[$grant_file],
    path      => [ '/usr/bin' , '/usr/sbin' ],
    creates   => $exec_flagfile,
  }

}
