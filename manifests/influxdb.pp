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
# @param manage If to actually manage any resource in this profile or not
# @param auto_prereq If to automatically install eventual dependencies.
#   Set to false if you have problems with duplicated resources, being sure that you
#   provide the needed prerequistes.
# @param options_hash An custom hash of keypair which may be used in templates to
#   manage any influxdb setting.
# @param module What module to use to manage influxdb. By default psick is used.
#   The specified module name, if different, must be added to Puppetfile.
# @param no_noop Set noop metaparameter to false to all the resources of this class.
#   This overrides any noop setting which might be in place.

class psick::influxdb (
  Psick::Ensure   $ensure                   = 'present',
  Boolean         $manage                   = $::psick::manage,
  Boolean         $auto_prereq              = $::psick::auto_prereq,
  Hash            $options_hash             = {},
  String          $module                   = 'psick',
  Boolean         $no_noop                  = false,
  Hash            $databases_hash           = {},
  Hash            $users_hash               = {},
  Hash            $grants_hash              = {},
) {

  # We declare resources only if $manage = true
  if $manage {

    # If no_noop is set it's enforced, unless psick::noop_mode is
    if !$::psick::noop_mode and $no_noop {
      info('Forced no-noop mode in psick::influxdb')
      noop(false)
    }

    # Managed resources according to $module selected
    case $module {
      'psick': {
        contain ::psick::influxdb::tp
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
