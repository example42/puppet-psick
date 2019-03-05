# Manages Windows users using VoxPupili windows_env module
# Prerequisite: mod: 'puppet-windows_env'
#
class psick::windows::envs (
  Optional[Hash] $envs_hash = {},
  Hash $resource_default_arguments = {},
) {

  Windows_env {
    * => $resource_default_arguments,
  }

  $envs_hash.each |$k,$v| {
    windows_env { $k:
      * => $v,
    }
  }
}
