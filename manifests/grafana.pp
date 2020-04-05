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
# @param auto_prereq If to automatically install eventual dependencies.
#   Set to false if you have problems with duplicated resources, being sure that you
#   provide the needed prerequistes.
# @param options_hash An custom hash of keypair which may be used in templates to
#   manage any grafana setting.
# @param module What module to use to manage grafana. By default psick is used.
#   The specified module name, if different, must be added to Puppetfile. 
# @param no_noop Set noop metaparameter to false to all the resources of this class.
#   This overrides any noop setting which might be in place.
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
class psick::grafana (
  Psick::Ensure   $ensure                   = 'present',
  Boolean         $auto_prereq              = $::psick::auto_prereq,
  Hash            $options_hash             = {},
  String          $module                   = 'tp_profile',

  String          $config_template          = 'psick/generic/inifile_with_stanzas.erb',

  Hash            $dashboards_hash          = {},
  Hash            $datasources_hash         = {},
  Hash            $plugins_hash             = {},

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
        contain ::tp_profile::grafana
      }
      default: {
        contain $module
      }
    }

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
    $plugins_hash.each | $k,$v | {
      psick::grafana::plugin { $k:
        * => $v,
      }
    }
  }
}
