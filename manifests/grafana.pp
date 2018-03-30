# psick::grafana
#
# @summary This psick profile manages grafana with Tiny Puppet (tp)
#
# @example Include it to install grafana
#   include psick::grafana
#
# @example Include in PSICK via hiera (yaml)
#   psick::profiles::linux_classes:
#     grafana: psick::grafana
#
# @example Set no-noop mode and enforce changes even if noop is set for the agent
#     psick::grafana::no_noop: true
#
# @param manage If to actually manage any resource in this profile or not
# @param auto_prereq If to automatically install eventual dependencies.
#   Set to false if you have problems with duplicated resources, being sure that you
#   provide the needed prerequistes.
# @param options_hash An custom hash of keypair which may be used in templates to
#   manage any grafana setting.
# @param module What module to use to manage grafana. By default psick is used.
#   The specified module name, if different, must be added to Puppetfile. 
# @param no_noop Set noop metaparameter to false to all the resources of this class.
#   This overrides any noop setting which might be in place.
class psick::grafana (
  Psick::Ensure   $ensure                   = 'present',
  Boolean         $manage                   = $::psick::manage,
  Boolean         $auto_prereq              = $::psick::auto_prereq,
  Hash            $options_hash             = {},
  String          $module                   = 'psick',
  Boolean         $no_noop                  = false,

  String          $config_template          = 'psick/generic/inifile_with_stanzas.erb',

  Hash            $dashboards_hash          = {},
  Hash            $datasources_hash         = {},
) {

  # We declare resources only if $manage = true
  if $manage {
    
    # If no_noop is set it's enforced, unless psick::noop_mode is 
    if !$::psick::noop_mode and $no_noop {
      info('Forced no-noop mode in psick::grafana')
      noop(false)
    }

    # Managed resources according to $module selected
    case $module {
      'psick': {
        contain ::psick::grafana::tp

        # Default config_template uses $parameters var. We manage it if data is
        # provided
        $parameters = $options_hash
        if $parameters != {} {
          tp::conf { 'grafana':
            content => template($config_template),
          }
        }
        $datasources_hash.each | $k,$v | {
          psick::grafana::datasource { $k:
            * => $v,
          }
        }
        $dashboards_hash.each | $k,$v | {
          psick::grafana::dashboard { $k:
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
