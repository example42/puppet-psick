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

  Optional[String] $hostname = undef,

  Optional[String]                    $host_conf_template = undef,
  Hash                                $host_conf_options  = {},

  Optional[String]                $nsswitch_conf_template = undef,
  Hash                            $nsswitch_conf_options  = {},

  Boolean $use_netplan                                    = false,
  # This "param" is looked up in code according to interfaces_merge_behaviour
  # Optional[Hash]              $interfaces               = undef,
  Enum['first','hash','deep'] $interfaces_merge_behaviour = 'first',
  Hash                        $interfaces_defaults        = {},

  # This "param" is looked up in code according to routes_merge_behaviour
  # Optional[Hash]              $routes                   = undef,
  Enum['first','hash','deep'] $routes_merge_behaviour     = 'first',
  Hash                        $routes_defaults            = {},

  # This "param" is looked up in code according to rules_merge_behaviour
  # Optional[Hash]              $rules                    = undef,
  Enum['first','hash','deep'] $rules_merge_behaviour      = 'first',
  Hash                        $rules_defaults             = {},

  # This "param" is looked up in code according to tables_merge_behaviour
  # Optional[Hash]              $tables                   = undef,
  Enum['first','hash','deep'] $tables_merge_behaviour     = 'first',
  Hash                        $tables_defaults            = {},

  String $service_restart_exec                            = 'service network restart',
  Variant[Resource,String[0,0],Undef,Boolean] $config_file_notify  = true,
  Variant[Resource,String[0,0],Undef,Boolean] $config_file_require = undef,
  Boolean $config_file_per_interface                     = true,

) {
  # We declare resources only if $manage = true
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $manage_config_file_notify = $config_file_notify ? {
      true    => "Exec[${service_restart_exec}]",
      false   => undef,
      ''      => undef,
      undef   => undef,
      default => $config_file_notify,
    }
    $manage_config_file_require  = $config_file_require ? {
      true    => undef,
      false   => undef,
      ''      => undef,
      undef   => undef,
      default => $config_file_require,
    }

    # Exec to restart interfaces
    exec { $service_restart_exec :
      command     => $service_restart_exec,
      alias       => 'network_restart',
      refreshonly => true,
      path        => $facts['path'],
    }

    if $hostname {
      contain ::psick::network::hostname
    }

    # Manage /etc/host.conf if $host_conf_template is set
    if $host_conf_template {
      $host_conf_template_type=$host_conf_template[-4,4]
      $host_conf_content = $host_conf_template_type ? {
        '.epp'  => epp($host_conf_template, { options => $host_conf_options }),
        '.erb'  => template($host_conf_template),
        default => template($host_conf_template),
      }
      file { '/etc/host.conf':
        ensure  => present,
        content => $host_conf_content,
        notify  => $manage_config_file_notify,
      }
    }

    # Manage /etc/nsswitch.conf if $nsswitch_conf_template is set
    if $nsswitch_conf_template {
      $nsswitch_conf_template_type=$nsswitch_conf_template[-4,4]
      $nsswitch_conf_content = $nsswitch_conf_template_type ? {
        '.epp'  => epp($nsswitch_conf_template, { options => $nsswitch_conf_options }),
        '.erb'  => template($nsswitch_conf_template),
        default => template($nsswitch_conf_template),
      }
      file { '/etc/nsswitch.conf':
        ensure  => present,
        content => $nsswitch_conf_content,
        notify  => $manage_config_file_notify,
      }
    }

    # Declare network interfaces based on network::interfaces
    $interfaces = lookup('psick::network::interfaces',Hash,$interfaces_merge_behaviour, {})
    $interfaces.each |$k,$v| {
      psick::network::interface { $k:
        * => $interfaces_defaults + $v,
      }
    }

    # Declare network routes based on network::routes
    $routes = lookup('psick::network::routes',Hash,$routes_merge_behaviour, {})
    $routes.each |$k,$v| {
      psick::network::route { $k:
        * => $routes_defaults + $v,
      }
    }

    # Declare network rules based on network::rules
    $rules = lookup('psick::network::rules',Hash,$rules_merge_behaviour, {})
    $rules.each |$k,$v| {
      psick::network::rule { $k:
        * => $rules_defaults + $v,
      }
    }

    # Declare network tables based on network::tables
    $tables = lookup('psick::network::tables',Hash,$tables_merge_behaviour, {})
    $tables.each |$k,$v| {
      psick::network::table { $k:
        * => $tables_defaults + $v,
      }
    }
  }
}
