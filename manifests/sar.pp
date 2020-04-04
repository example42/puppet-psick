# Installs and configures sar
# Default settings manage SAR with checks every 5 minutes and daily summary
# creation.
#
# @param ensure if to install sysstat and create the /etc/cron.d/sysstat file
# @param check_cron The cron schedule for check interval. Default: */5 * * * *
# @param summary_cron The cron schedule for summary creation. Def: 53 23 * * *
# @param cron_template The erb template to use for the /etc/cron.d/sysstat file
# @param manage If to actually manage any resource in this class. If false no
#               resource is managed. Default value is taken from main psick class.
# @param noop_manage If to use the noop() function for all the resources provided
#                    by this class. If this is true the noop function is called
#                    with $noop_value argument. This overrides any other noop setting
#                    (either set on client's puppet.conf or by noop() function in
#                    main psick class). Default from psick class.
# @param noop_value The value to pass to noop() function if noop_manage is true.
#                   It applies to all the resources (and classes) declared in this class
#                   If true: noop metaparamenter is set to true, resources are not applied
#                   If false: noop metaparameter is set to false, and any eventual noop
#                   setting is overridden: resources are always applied.
#                   Default from psick class.
class psick::sar (
  String $ensure        = 'present',
  String $check_cron    = '*/5 * * * *',
  String $summary_cron  = '53 23 * * *',
  String $cron_template = 'psick/sar/systat.cron.erb',

  Boolean $manage       = $::psick::manage,
  Boolean $noop_manage  = $::psick::noop_manage,
  Boolean $noop_value   = $::psick::noop_value,

) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    package { 'sysstat':
      ensure => $ensure,
    }
    file { '/etc/cron.d/sysstat':
      ensure  => $ensure,
      content => template($cron_template),
    }
  }
}
