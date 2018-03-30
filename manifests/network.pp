# psick::network
#
# @summary This psick profile manages network settings, such as interfaces and
# routes.
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
  Psick::Ensure   $ensure                   = 'present',
  Boolean         $manage                   = $::psick::manage,
  Boolean         $auto_prereq              = $::psick::auto_prereq,
  Hash            $options_hash             = {},
  String          $module                   = 'psick',
  Boolean         $no_noop                  = false,

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

    # If no_noop is set it's enforced, unless $::psick::noop_mode is true 
    if !$::psick::noop_mode and $no_noop {
      info('Forced no-noop mode in psick::network')
      noop(false)
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
      'example42-network': {
        # Class psick::network::example42 was the initial implementation
        # of psick::network using example42-network module
        class { 'psick::network::example42':
          bonding_mode     => $bonding_mode, 
          network_template => $network_template,
          }
        }
      }
      default: {
        contain $module
      }
    }
  }
}
