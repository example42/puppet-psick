# Manages Windows users using Puppet user type
class psick::windows::users (
  Optional[Hash] $users_hash = {},
  Hash $resource_default_arguments = {},
) {

  User {
    * => $resource_default_arguments,
  }

  $users_hash.each |$k,$v| {
    user { $k:
      * => $v,
    }
  }
}
