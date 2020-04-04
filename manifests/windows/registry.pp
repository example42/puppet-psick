# Requires puppetlabs/registry module
class psick::windows::registry (
  Optional[Hash] $keys     = {},
  Optional[Hash] $defaults = {},
  Boolean $use_defaults    = true,

  Boolean $manage      = $::psick::manage,
  Boolean $noop_manage = $::psick::noop_manage,
  Boolean $noop_value  = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $registry = $use_defaults ? {
      true  => $keys + $defaults,
      false => $keys,
    }

    $registry.each |$k,$v| {
      registry::value { $k:
        * => $v,
      }
    }
  }
}
