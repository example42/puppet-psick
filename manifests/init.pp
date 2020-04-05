# @description PSICK - The Infrastructure Puppet module entry class
#
# The main psick class. From here the whole infrastructure can be built.
# This class exposes parameters that serve as entry points to set general
# settings used by other psick profiles.
# When included, this class does nothing by default, but it's required to
# be able to use PSICK for classification and/or to use any PSICK profile.
#
# @param manage If to actually manage the resources of a class. This allows
#   to skip management of resources even if classes are included. Used
#   to avoid to manage some resources when building Docker images.
# @param auto_prereq If to automtically manage prerequisites. Set to false here to
#   apply this value for all the PSICK profiles that honour this global
#   setting. Use when you have duplicated resources.
# @param enable_firstrun If to enable firstrun mode, a special one-time only, Puppet
#   run where some specific, prerequisites, classes are applied.
# @param noop_mode This parameter is deprecated and has no effect any more.
#                  If set, compilation fails.
#                  It has been replaced by noop_manage and noop_value.
#                  psick::noop_mode: true and no_noop on a specific class can be replaced by:
#                  psick::noop_manage: true
#                  psick::noop_value: false
# @param noop_manage If to use the noop() function for all the classes included
#                    in this module. If this is true the noop($noop_value) function
#                    is called. Overriding any other noop setting (either set on
#                    client's puppet.conf or elsewhere).
#                    This values is inherited by all the classes in psick module
#                    but can singularly overwritten in each of them.
# @param noop_value The value to pass to noop() function if noop_manage is true.
#                   It applies to all the resources (and classes) declared in
#                   this module. Can be overridden is single classes using the
#                   relevant class parameter.
#                   If true: noop metaparamenter is set to true, resources are not applied
#                   If false: noop metaparameter is set to false, and any eventual noop
#                   setting is overridden: resources are always applied.
# @param is_cluster Defines if the server is a cluster member. Some PSICK profiles
#   may use this value.
# @param primary_ip The server primary IP address. Default value is
#   the value of the $::networking['ip'] fact.
# @param mgmt_interface The management interface of the server. Default value is
#   the value of the $::networking['primary'] fact.
# @param timezone The timezone to set on the system. Single entry point used by
#   some PSICK profiles.
# @param settings An hash of custom settings which can be used to configure any
#   settings which might be used in different profiles. This is not used in any
#   existing PSICK profiles, but can be referenced in any custom profile classified
#   via PSICK.
# @param servers An hash which describes general infrastructure endpoints which
#   can be used by different (PSICK or local) profiles. Used in psick::proxy and
#   whenever it might be needed to refer to a single endpoint used by differenet
#   classes / profiles.
# @param tp An hash to configure behaviour of tp defines. It's used to set resource
#   defaults for tp::install, tp::conf and tp::dir.
# @param firewall An hash of general firewall settings. Can be used and honoured by
#   other psick profiles. Customise as needed.
# @param monitor An hash of general monitor settings. Can be used and honoured by
#   other psick profiles. Customise as needed.
# @param force_ordering When enabled, as default, the psick module enforces
#   ordering of the classes included in psick::pre -> psick::base ->
#   psick::profiles. Disable only if you have unresolvable dependency loops or
#   if you don't want the PSICK class provisioning staged in different phases.
#
# @example Sample data for proxy server hash
#     psick::servers:
#       proxy:
#         host: proxy.example.com
#         port: 3128
#         user: john    # Optional
#         password: xxx # Optional
#         no_proxy:
#           - localhost
#           - "%{::domain}"
#         scheme: http
#
class psick (

  # PSICK global vars
  Boolean $manage                                  = true,
  Boolean $auto_prereq                             = true,
  Boolean $enable_firstrun                         = false,

  Optional[Boolean] $noop_mode                     = lookup('noop_mode',Optional[Boolean],'first',undef),
  Boolean $noop_manage                             = false,
  Boolean $noop_value                              = false,

  # General network settings
  Boolean $is_cluster = false,
  Optional[Stdlib::Compat::Ip_address] $primary_ip = fact('networking.ip'),
  Optional[String] $mgmt_interface                 = fact('networking.primary'),
  Optional[String] $timezone                       = undef,
  Hash $interfaces_hash                            = {},

  # General endpoints and variables
  Hash $settings                                   = {},
  Hash $servers                                    = {},
  Hash $tp                                         = {},
  Hash $firewall                                   = {},
  Hash $monitor                                    = {},
  Boolean $force_ordering                          = true,

) {

  if $noop_mode != undef {
    fail('psick::noop_mode parameter has been deprecated. Use $noop_manage and $noop_manage instead')
  }
  if $noop_manage {
    noop($noop_value)
  }

  # Resource defaults for Tiny Puppet defines
  Tp::Install {
    cli_enable   => $tp['cli_enable'],
    test_enable  => $tp['test_enable'],
    puppi_enable => $tp['puppi_enable'],
    debug        => $tp['debug'],
    data_module  => $tp['data_module'],
  }
  Tp::Conf {
    config_file_notify  => $tp['config_file_notify'],
    config_file_require => $tp['config_file_require'],
    debug               => $tp['debug'],
    data_module         => $tp['data_module'],
  }
  Tp::Dir {
    config_dir_notify  => $tp['config_dir_notify'],
    config_dir_require => $tp['config_dir_require'],
    debug              => $tp['debug'],
    data_module        => $tp['data_module'],
  }

  # Building of the $::psick::interfaces variable, usable in any class included
  # via or after psick.
  # By default are set main and mgmt interfaces based on sane facts values and
  # user params $primary_ip and $mgmt_interface
  $primary_interface =  $facts['networking']['primary']
  $interfaces_default = {
    main => {
      interface => $facts['networking']['primary'],
      address   => pick($primary_ip, $facts['networking']['interfaces'][$primary_interface]['ip']),
      netmask   => $facts['networking']['interfaces'][$primary_interface]['netmask'],
      network   => $facts['networking']['interfaces'][$primary_interface]['network'],
      hostname  => $facts['networking']['fqdn'],
    },
    mgmt => {
      interface => $mgmt_interface,
      address   => $facts['networking']['interfaces'][$mgmt_interface]['ip'],
      netmask   => $facts['networking']['interfaces'][$mgmt_interface]['netmask'],
      network   => $facts['networking']['interfaces'][$mgmt_interface]['network'],
      hostname  => $facts['networking']['fqdn'],
    }
  }
  $interfaces = deep_merge($interfaces_default, $interfaces_hash)


  # PSICK PRE, BASE CLASSES AND PROFILES + OPTIONAL FIRSTRUN MODE
  # The classes included here manage PSICK classification and
  # relevant class ordering
  if $facts['firstrun'] == 'done' or $enable_firstrun == false {
    contain ::psick::pre
    contain ::psick::base
    contain ::psick::profiles
    if $force_ordering {
      Class['psick::pre'] -> Class['psick::base'] -> Class['psick::profiles']
    }
  } else {
    contain ::psick::firstrun
    notify { "This catalog should be applied only at the first Puppen run\n": }
  }

}
