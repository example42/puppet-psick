# Class psick::time
# This class manages time on different OS in various ways:
#
# @param servers Arrays of ntp servers to set
# @param method How to set time via ntp.
#    chrony - use Chrony. Requires aboe/chrony module
#    ntp - use official Puppet Ntp module. Requires puppetlabs/ntp
#    ntpdate - Schedule ntp updates via psick::time::ntpdate
#
# On Windows the psick::windows::time class is used to set ntp.
#
class psick::time (
  Array $servers                            = [],
  Optional[String] $timezone                = $psick::timezone,
  Enum['chrony','ntpdate','ntp',''] $method = 'ntpdate',

  Boolean             $manage               = $psick::manage,
  Boolean             $noop_manage          = $psick::noop_manage,
  Boolean             $noop_value           = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $facts['kernel'] != 'windows' and $timezone {
      contain psick::timezone
    }

    if $facts['kernel'] == 'Linux' and $method == 'chrony' {
      class { 'chrony':
        servers => $servers,
      }
    }

    if $facts['kernel'] == 'Linux' and $method == 'ntpdate' {
      contain psick::time::ntpdate
    }

    if $facts['kernel'] != 'Windows' and $method == 'ntp' {
      class { 'ntp':
        servers => $servers,
      }
    }

    if $facts['os']['family'] == 'Windows' {
      contain psick::time::windows
    }
  }
}
