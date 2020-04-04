#
# Class: psick::mariadb::root_password
#
# Set mariadb root password
#
class psick::mariadb::root_password (
  String $root_cnf_template = 'psick/mariadb/root.my.cnf.erb',
  Optional[Psick::Password] $password = $::psick::mariadb::root_password,
  Boolean $manage             = $::psick::manage,
  Boolean $noop_manage        = $::psick::noop_manage,
  Boolean $noop_value         = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    if ! defined(File['/root/.my.cnf']) {
      file { '/root/.my.cnf':
        ensure  => 'present',
        path    => '/root/.my.cnf',
        mode    => '0400',
        content => template($root_cnf_template),
      }
    }

    file { '/root/.my.cnf.backup':
      ensure  => 'present',
      path    => '/root/.my.cnf.backup',
      mode    => '0400',
      content => template('psick/mariadb/root.my.cnf.backup.erb'),
      replace => false,
      before  => [Exec['mariadb_root_password'],
                  Exec['mariadb_backup_root_my_cnf'] ],
    }

    exec { 'mariadb_backup_root_my_cnf':
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      unless  => 'diff /root/.my.cnf /root/.my.cnf.backup',
      command => 'cp /root/.my.cnf /root/.my.cnf.backup ; true',
      before  => File['/root/.my.cnf'],
    }

    exec { 'mariadb_root_password':
      subscribe   => File['/root/.my.cnf'],
      path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      refreshonly => true,
      command     => "mysqladmin --defaults-file=/root/.my.cnf.backup -uroot password '${psick::mariadb::root_password}'",
    }
  }
}
