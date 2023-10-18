# Manages Windows services using Puppet service type
class psick::windows::services (
  Hash $managed  = {},
  Hash $defaults = {},
  Boolean $use_defaults    = true,

  Boolean $manage      = $psick::manage,
  Boolean $noop_manage = $psick::noop_manage,
  Boolean $noop_value  = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $services = $use_defaults ? {
      true  => $managed + $defaults,
      false => $managed,
    }

    $services.each |$k,$v| {
      service { $k:
        * => $v,
      }
    }
  }
}
