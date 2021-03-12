# Installs and configures sar
#
class psick::monitor::sar (
  String $ensure        = 'present',
  String $check_cron    = '*/5 * * * *',
  String $summary_cron  = '53 23 * * *',
  String $cron_template = 'psick/sar/systat.cron.erb',
  Optional[String] $package_name = 'sysstat',
  Boolean $manage       = $::psick::manage,
  Boolean $noop_manage  = $::psick::noop_manage,
  Boolean $noop_value   = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    if $package_name and $package_name != '' {
      package { $package_name:
        ensure => $ensure,
      }
      file { '/etc/cron.d/sysstat':
        ensure  => $ensure,
        content => template($cron_template),
      }
    }
  }
}
