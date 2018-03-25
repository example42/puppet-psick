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
# @param auto_conf Which autoconfiguration layout to use. Default is 'none', if you
#   set 'hardened' some hardened configurations are enforced by default
# @param enable_firstrun If to enable firstrun mode, a special one-time only, Puppet
#   run where some specific, prerequisites, classes are applied.
# @param noop_mode Psick's noop mode. Looks for the hiera key noop_mode to check
#   if to enable noop mode in the module itself. The same is done on the default
#   psick-control repo. Note that if noop_mode is set to true here (or in
#   Hiera's noop_mode key) the no-noop params in the psick profiles are not
#   valid: If noop_mode is true, noop is enforced also where no-noop is true.
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
  Psick::Autoconf $auto_conf                       = 'none',
  Boolean $enable_firstrun                         = false,
  Boolean $noop_mode                               = lookup('noop_mode', Boolean,'first',true),

  # General network settings
  Boolean $is_cluster = false,
  Optional[Stdlib::Compat::Ip_address] $primary_ip = fact('networking.ip'),
  Optional[String] $mgmt_interface                 = fact('networking.primary'),
  Optional[String] $timezone                       = undef,

  # General endpoints and variables
  Hash $settings                                   = {},
  Hash $servers                                    = {},
  Hash $tp                                         = {},
  Hash $firewall                                   = {},
  Hash $monitor                                    = {},
  Boolean $force_ordering                          = true,

) {

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
