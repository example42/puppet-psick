# This class installs Gsnglia packages and starts the gmond service
#
class psick::monitor::ganglia (
  Array $packages,
  Boolean $manage             = $::psick::manage,
  Boolean $noop_manage        = $::psick::noop_manage,
  Boolean $noop_value         = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $packages.each |$pkg| {
      ensure_packages($pkg)
    }

    #TODO: Verify for other OS
    #TODO: Verify if other cofnigs are needed
    service { 'gmond':
      ensure => 'running',
      enable => true,
    }
  }
}
