# Sample psick used by VMs in ostest Vagrant environment
# Used to code testing on different OS
#
class psick::ostest (
  Boolean $notify_enable = false,
  Hash $tp_install_hash  = {},
  Boolean $manage        = $psick::manage,
  Boolean $noop_manage   = $psick::noop_manage,
  Boolean $noop_value    = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $notify_enable {
      notify { 'ostest role': }
    }

    $tp_install_hash.each |$k,$v| {
      tp::install { $k:
        * => $v,
      }
    }
  }
}
