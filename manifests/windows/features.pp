# Requires puppet/windowsfeature module
class psick::windows::features (
  Optional[Hash] $install  = {},
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

    $features = $use_defaults ? {
      true  => $install + $defaults,
      false => $install,
    }

    $features.each |$k,$v| {
      windowsfeature { $k:
        * => $v,
      }
    }
  }
}
