#
class psick::hosts::resource (
  Optional[Hash] $hosts    = {},
  Optional[Hash] $defaults = {},
  Boolean $use_defaults    = true,

  Boolean $no_noop         = false,
) {

  if !$::psick::noop_mode and $no_noop {
    info('Forced no-noop mode.')
    noop(false)
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
