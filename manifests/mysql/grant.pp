# Define psick::mysql::grant
#
# This define adds a grant to the MySQL server. It creates a file with the
# grant statement and then applies it.
#
# Supported arguments:
# $db                 - The database to apply the grant to.
#                             If not set, defaults to == $title
#                             It supports SQL wildcards (%), ie: 'somedatab%'.
#                             The special value '*' means 'ALL DATABASES'
# $user               - User to grant the permissions to.
# $password           - Plaintext password for the user.
# $create_db          - If you want a $db database created or not.
#                             Default: true.
# $privileges         - Privileges to grant to the user.
#                             Defaults to 'ALL'
# $host               - Host where the user can connect from. Accepts SQL wildcards.
#                             Default: 'localhost'
# $grant_filepath     - Path where the grant files will be stored.
#                             Default: '/root/puppet-mysql'
# $db_init_query_file - Location of a sql file typically used to create the schema.
#                             $create_db must be true or the database must exist.
#                             Default: ''
# $remote_host              - Host on which to run the command. If not specified, the
#                             command will be run on localhost.
#                             Default: ''
# $remote_user              - User to connect with when running the command on a remote
#                             server.
#                             Default: ''
# $remote_password          - Password to use when running the command on a remote server.
#                             Default: ''
# $require_ssl              - Define if SSL connection is required for the user.
#                             Default: false
define psick::mysql::grant (
  $password,
  $user               = $title,
  $ensure             = 'present',
  $db                 = '',
  $db_create_options  = '',
  $create_db          = true,
  $privileges         = 'ALL',
  $host               = 'localhost',
  $grant_filepath     = '/root/puppet-mysql',
  $db_init_query_file = '',
  $remote_host        = '',
  $remote_user        = '',
  $remote_password    = '',
  $require_ssl        = false,
  ) {

  $dbname = $db ? {
    ''      => $name,
    default => $db,
  }
  $real_db_create_options = $db_create_options ? {
    ''      => '',
    default => " ${db_create_options}",
  }

  # Check for wildcards
  $real_db = $dbname ? {
    /^(\*|%)$/ => '*',
    default    => "`${dbname}`",
  }

  $nice_host = regsubst($host, '/', '_')

  $grant_file_host = $remote_host ? {
    ''      => '',
    default => "-${remote_host}",
  }

  $grant_file = $dbname ? {
    /^(\*|%)$/ => "mysqlgrant${grant_file_host}-${user}-${nice_host}-all.sql",
    default    => "mysqlgrant${grant_file_host}-${user}-${nice_host}-${dbname}.sql",
  }

  $grant_template = $ensure ? {
    'absent' => 'psick/mysql/revoke.erb',
    default  => 'psick/mysql/grant.erb',
  }

  # If dbname has a wildcard, we don't want to create anything
  $bool_create_db = $dbname ? {
    /(\*|%)/ => false,
    default  => any2bool($create_db)
  }

  $manage_remote_host = $remote_host ? {
    ''      => 'localhost',
    default => $remote_host,
  }

  if (!defined(File[$grant_filepath])) {
    file { $grant_filepath:
      ensure => directory,
      path   => $grant_filepath,
      owner  => 'root',
      group  => 'root',
      mode   => '0700',
    }
  }

  file { $grant_file:
    ensure  => present,
    mode    => '0600',
    owner   => 'root',
    group   => 'root',
    path    => "${grant_filepath}/${grant_file}",
    content => template($grant_template),
  }

  if getvar('psick::mysql::root_password') {
    $my_cnf = '--defaults-file=/root/.my.cnf'
  } else {
    $my_cnf = ''
  }

  $exec_flagfile = "${grant_filepath}/${grant_file}.done"
  $exec_command = $remote_host ? {
    ''      => "mysql ${my_cnf} -uroot < ${grant_filepath}/${grant_file}",
    default => "mysql -h${remote_host} -u${remote_user} --password=${remote_password} < ${grant_filepath}/${grant_file}",
  }

  exec { "remove_${exec_flagfile}":
    command     => "rm -f '${exec_flagfile}'",
    subscribe   => File[$grant_file],
    path        => [ '/usr/bin' , '/usr/sbin' ],
    refreshonly => true,
    before      => Exec["mysqlgrant-${user}-${nice_host}-${dbname}"],
  }

  exec { "mysqlgrant-${user}-${nice_host}-${dbname}":
    command   => "${exec_command} && touch ${exec_flagfile}",
    subscribe => File[$grant_file],
    path      => [ '/usr/bin' , '/usr/sbin' ],
    creates   => $exec_flagfile,
  }

  if $db_init_query_file != '' and $create_db == true {
    psick::mysql::sqlfile { "db_init_query_file-${nice_host}-${dbname}":
      file      => $db_init_query_file,
      user      => $remote_user,
      password  => $remote_password,
      db        => $dbname,
      host      => $manage_remote_host,
      subscribe => Exec["mysqlgrant-${user}-${nice_host}-${dbname}"],
    }
  }
}
