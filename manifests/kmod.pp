# psick::kmod
#
# @summary This psick profile manages kernel modules
#
# @example Include it to install kmod
#   include psick::kmod
#
# @example Include in PSICK via hiera (yaml)
#   psick::profiles::linux_classes:
#     kmod: psick::kmod
#
# @param modules An hash of psick::kmod::module resources to configure.
#   This is not actually a class parameter, but a key looked up using the
#   merge behaviour configured via $modules_merge_behaviour.
# @param modules_merge_behaviour Defines the lookup method to use to
#   retrieve via hiera the $modules hash
# @param manage If to actually manage any resource in this profile or not
# @param noop_manage If to use the noop() function for all the resources provided
#   by this class. If this is true the noop function is called with $noop_value argument.
#   This overrides any other noop setting (either set on client's puppet.conf or by noop()
#   function in main psick class).
# @param noop_value The value to pass to noop() function if noop_manage is true.
#   It applies to all the resources (and classes) declared in this class.
#   If true: noop metaparamenter is set to true, resources are not applied
#   If false: noop metaparameter is set to false, any eventual noop setting is overridden
#   and resources are always applied.
#
class psick::kmod (
  Boolean         $manage                   = $::psick::manage,
#  Hash            $modules                  = {},
  Enum['first','hash','deep'] $modules_merge_behaviour = 'first',
  Boolean         $noop_manage              = $::psick::noop_manage,
  Boolean         $noop_value               = $::psick::noop_value,

) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    $modules = lookup('psick::kmod::modules',Hash,$modules_merge_behaviour,{})
    $modules.each | $k,$v | {
      psick::kmod::module { $k:
        * => $v,
      }
    }
  }
}
