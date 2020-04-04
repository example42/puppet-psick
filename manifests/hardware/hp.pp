# This class installs the packages needed for HP tools on HP hardware
# and starts the relevant services.
# It also add sudo directives for the hpsmh group
#
class psick::hardware::hp (
  Array $packages,
  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    $packages.each |$pkg| {
      ensure_packages($pkg)
    }

    service { 'hp-asrd':
      ensure => 'stopped',
      enable => false,
    }
    service { 'hp-health':
      ensure => 'running',
      enable => true,
    }
    service { 'hp-snmp-agents':
      ensure => 'running',
      enable => true,
    }

    psick::sudo::directive { 'hp':
      source => 'puppet:///modules/psick/sudo/hp',
    }
  }
}
