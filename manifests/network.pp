# psick::network
#
# @summary This psick profile manages network settings, such as interfaces and
# routes.
# @param bonding_mode Define bonding mode (default: active-backup)
# @param network_template The erb template to use, only on RedHad derivatives,
#                         for the file /etc/sysconfig/network
# @param routes Hash of routes to pass to ::network::mroute define
#               Note: This is not a real class parameter but a key looked up
#               via lookup('psick::network::routes', {})
# @param interfaces Hash of interfaces to pass to ::network::interface define
#                   Note: This is not a real class parameter but a key looked up
#                   via lookup('psick::network::interfaces', {})
#                   Note that this psick automatically adds some default
#                   options according to the interface type. You can override
#                   them in the provided hash
#
# @example Include it to manage network resources
#   include psick::network
#
# @example Include in PSICK via hiera (yaml)
#   psick::profiles::linux_classes:
#     network: psick::network
#
# @example Set no-noop mode and enforce changes even if noop is set for the agent
#     psick::network::no_noop: true
#
# @param manage If to actually manage any resource in this profile or not
# @param auto_prereq If to automatically install eventual dependencies.
#   Set to false if you have problems with duplicated resources, being sure that you
#   provide the needed prerequistes.
# @param options_hash An custom hash of keypair which may be used in templates to
#   manage any network setting.
# @param module What module to use to manage network. By default psick is used.
#   The specified module name, if different, must be added to Puppetfile. 
# @param no_noop Set noop metaparameter to false to all the resources of this class.
#   This overrides any noop setting which might be in place.
class psick::network (
  Psick::Ensure   $ensure               = 'present',
  Boolean         $manage               = $psick::manage,
  Boolean         $auto_prereq          = $psick::auto_prereq,
  Hash            $options_hash         = {},
  String          $module               = 'psick',
  Boolean          $noop_manage         = $psick::noop_manage,
  Boolean          $noop_value          = $psick::noop_value,

  # Legacy params now passed tp psick::network::example42
  String $bonding_mode     = 'active-backup',
  String $network_template = 'psick/network/network.erb',

  # Generic Hashes of resources and options
  Hash $interfaces_hash      = {},
  Hash $interfaces_default_options_hash = {},

  Hash $routes_hash      = {},

) {
  # We declare resources only if $manage = true
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    # Managed resources according to $module selected
    case $module {
      'psick': {
        $routes_hash.each |$r,$o| {
          ::psick::network::route { $r:
            * => $o,
          }
        }
        $interfaces_hash.each |$i,$o| {
          ::psick::network::interface { $i:
            * => $interfaces_default_options_hash + $o,
          }
        }
      }
      default: {
        contain $module
      }
    }
  }
}
