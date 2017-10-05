#
# Class: psick::mysql::root_password
#
# Set mysql root password
#
class psick::mysql::root_password (
  String $root_cnf_template = 'psick/mysql/root.my.cnf.erb',
  Optional[Psick::Password] $password = $::psick::mysql::root_password,
) {

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
    content => template('psick/mysql/root.my.cnf.backup.erb'),
    replace => false,
    before  => [Exec['mysql_root_password'],
                Exec['mysql_backup_root_my_cnf'] ],
  }

  exec { 'mysql_backup_root_my_cnf':
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    unless  => 'diff /root/.my.cnf /root/.my.cnf.backup',
    command => 'cp /root/.my.cnf /root/.my.cnf.backup ; true',
    before  => File['/root/.my.cnf'],
  }

  exec { 'mysql_root_password':
    subscribe   => File['/root/.my.cnf'],
    path        => '/bin:/sbin:/usr/bin:/usr/sbin',
    refreshonly => true,
    command     => "mysqladmin --defaults-file=/root/.my.cnf.backup -uroot password '${psick::mysql::root_password}'",
  }

}
