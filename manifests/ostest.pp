# Sample psick used by VMs in ostest Vagrant environment
# Used to code testing on different OS
#
class psick::ostest (
  Boolean $manage        = $::psick::manage,
  Boolean $notify_enable = false,
  Hash $tp_profiles_hash = {},
  Boolean $no_noop       = false,
) {
  if $manage {
    if !$::psick::noop_mode and $no_noop {
      info('Forced no-noop mode in psick::icinga2')
      noop(false)
    }

    if $notify_enable {
      notify { 'ostest role': }
    }

    $tp_profiles_hash.each |$k,$v| {
      class { "tp_profile::${k}":
        * => $v,
      }
    }
  }
}
