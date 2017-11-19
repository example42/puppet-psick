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
  Optional[String] $timezone                = $::psick::timezone,
  Enum['chrony','ntpdate','ntp',''] $method = 'ntpdate',
) {

  if $::kernel != 'windows' and $timezone {
    contain ::psick::timezone
  }

  if $::kernel == 'Linux' and $method == 'chrony' {
    class { '::chrony':
      servers => $servers,
    }
  }

  if $::kernel == 'Linux' and $method == 'ntpdate' {
    contain ::psick::time::ntpdate
  }

  if $::kernel != 'Windows' and $method == 'ntp' {
    class { '::ntp':
      servers => $servers,
    }
  }

  if $::osfamily == 'Windows' {
    contain ::psick::time::windows
  }

}
