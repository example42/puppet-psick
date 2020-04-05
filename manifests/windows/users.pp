# Manages Windows users using Puppet user type
class psick::windows::users (
  Optional[Hash] $users_hash = {},
  Hash $resource_default_arguments = {},

  Boolean $manage      = $::psick::manage,
  Boolean $noop_manage = $::psick::noop_manage,
  Boolean $noop_value  = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    User {
      * => $resource_default_arguments,
    }

    $users_hash.each |$k,$v| {
      user { $k:
        * => $v,
      }
    }
  }
}
