# This class installs and runs once ntpdate
class psick::time::ntpdate (
  # If given a ntpdate cron jon is scheduled. Format: * * * * *
  String $crontab    = '',

  # Server to sync to (just one)
  String $ntp_server = 'pool.ntp.org',

  Boolean $manage      = $::psick::manage,
  Boolean $noop_manage = $::psick::noop_manage,
  Boolean $noop_value  = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    tp::install { 'ntpdate': }

    exec { "ntpdate -s ${ntp_server}":
      subscribe   => Tp::Install['ntpdate'],
      refreshonly => true,
      path        => $::path
    }
    if $crontab != '' and $::virtual != 'docker' {
      file { '/etc/cron.d/ntpdate':
        content => "${crontab} root ntpdate -s ${ntp_server}\n",
      }
    }
  }
}
