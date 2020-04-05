# This class installs PE client tools
#
class psick::puppet::pe_client_tools (
  Enum['present','absent'] $ensure = present,
  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    package { 'pe-client-tools':
      ensure => $ensure,
    }
  }
}
