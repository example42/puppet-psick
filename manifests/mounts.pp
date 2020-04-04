# Generic class to manage mount resources
#
# @description This class exposes the mounts parameter which allows management
#   via hiera of mount resources
#
# @param mounts An hash of mount resources wiuth parameter passed to mount
#               Key values of each hash element are normal paramerts of the
#               mount resource type
# @param manage If to actually manage any resource in this class. If false no
#               resource is managed.
# @param noop_manage If to use the noop() function for all the resources provided
#                    by this class. If this is true the noop function is called
#                    with $noop_value argument. This overrides any other noop setting
#                    (either set on client's puppet.conf or by noop() function in
#                    main psick class).
# @param noop_value The value to pass to noop() function if noop_manage is true.
#                   It applies to all the resources (and classes) declared in this class
#                   If true: noop metaparamenter is set to true, resources are not applied
#                   If false: noop metaparameter is set to false, and any eventual noop
#                   setting is overridden: resources are always applied.
#
# @example
#   include psick::mounts
class psick::mounts (
  Hash    $mounts      = {},

  Boolean $manage      = $::psick::manage,
  Boolean $noop_manage = $::psick::noop_manage,
  Boolean $noop_value  = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $mounts.each |$k,$v| {
      mount { $k:
        * => $v,
      }
    }
  }
}
