#
class psick::hosts::resource (
  Optional[Hash] $hosts    = {},
  Optional[Hash] $defaults = {},
  Boolean $use_defaults    = true,

  Boolean $manage          = $::psick::manage,
  Boolean $noop_manage     = $::psick::noop_manage,
  Boolean $noop_value      = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $all_hosts = $use_defaults ? {
      true  => $hosts + $defaults,
      false => $hosts,
    }

    $all_hosts.each |$k,$v| {
      host { $k:
        *    => $v,
      }
    }
  }
}
