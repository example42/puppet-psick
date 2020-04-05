# class psick::puppet::foss_server_metrics
#
# activates the graphite pushed puppet internal server metrics
#
# @param graphite_server
#  this parameter must be set!
#
class psick::puppet::foss_server_metrics (
  String $graphite_server,
  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    Hocon_setting {
      path   => '/etc/puppetlabs/puppetserver/conf.d/metrics.conf',
      notify => Service['puppetserver'],
    }
    hocon_setting {'server metrics reporters graphite':
      ensure  => present,
      setting => 'metrics.registries.puppetserver.reporters.graphite.enabled',
      value   => true,
    }
    hocon_setting {'server metrics graphite host':
      ensure  => present,
      setting => 'metrics.reporters.graphite.host',
      value   => $graphite_server,
    }
    hocon_setting {'server metrics graphite port':
      ensure  => present,
      setting => 'metrics.reporters.graphite.port',
      value   => 2003,
    }
    hocon_setting {'server metrics graphite update interval':
      ensure  => present,
      setting => 'metrics.reporters.graphite.update-interval-seconds',
      value   => 5,
    }
  }
}
