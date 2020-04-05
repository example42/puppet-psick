# psick::influxdb
#
# @summary This psick profile manages influxdb with Tiny Puppet (tp)
#
# @example Include it to install influxdb
#   include psick::influxdb
#
# @example Include in PSICK via hiera (yaml)
#   psick::profiles::linux_classes:
#     influxdb: psick::influxdb
#
# @example Set no-noop mode and enforce changes even if noop is set for the agent
#     psick::influxdb::no_noop: true
#
# @param auto_prereq If to automatically install eventual dependencies.
#   Set to false if you have problems with duplicated resources, being sure that you
#   provide the needed prerequistes.
# @param options_hash An custom hash of keypair which may be used in templates to
#   manage any influxdb setting.
# @param module What module to use to manage influxdb. By default psick is used.
#   The specified module name, if different, must be added to Puppetfile.
# @param manage If to actually manage any resource in this class. If false no
#               resource is managed. Default value is taken from main psick class.
# @param noop_manage If to use the noop() function for all the resources provided
#                    by this class. If this is true the noop function is called
#                    with $noop_value argument. This overrides any other noop setting
#                    (either set on client's puppet.conf or by noop() function in
#                    main psick class). Default from psick class.
# @param noop_value The value to pass to noop() function if noop_manage is true.
#                   It applies to all the resources (and classes) declared in this class
#                   If true: noop metaparamenter is set to true, resources are not applied
#                   If false: noop metaparameter is set to false, and any eventual noop
#                   setting is overridden: resources are always applied.
#                   Default from psick class.
#
class psick::influxdb (
  Psick::Ensure   $ensure                   = 'present',
  Boolean         $auto_prereq              = $::psick::auto_prereq,
  Hash            $options_hash             = {},
  String          $module                   = 'tp_profile',

  Hash            $databases_hash           = {},
  Hash            $users_hash               = {},
  Hash            $grants_hash              = {},

  Boolean         $manage                   = $::psick::manage,
  Boolean         $noop_manage              = $::psick::noop_manage,
  Boolean         $noop_value               = $::psick::noop_value,

) {

  # We declare resources only if $manage = true
  if $manage {

    if $noop_manage {
      noop($noop_value)
    }

    # Managed resources according to $module selected
    case $module {
      'tp_profile': {
        contain ::tp_profile::influxdb
        #$users_hash.each | $k,$v | {
        #  psick::influxdb::users { $k:
        #    * => $v,
        #  }
        #}
        $databases_hash.each | $k,$v | {
          psick::influxdb::database { $k:
            * => $v,
          }
        }
        $users_hash.each | $k,$v | {
          psick::influxdb::user { $k:
            * => $v,
          }
        }
        $grants_hash.each | $k,$v | {
          psick::influxdb::grant { $k:
            * => $v,
          }
        }

      }
      default: {
        contain $module
      }
    }
  }
}
