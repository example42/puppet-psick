# The main psick class. From here the whole infrastructure can be built.
# This class exposes parameters that:entry point to set general settings used by other psick profiles
#
# @param is_cluster Defines if the server is a cluster member
# @param primary_ip_address The server primary IP address. Default value is
#                           automatically calculated based on the mgmt_interface
#                           address. The resulting variable, used in other
#                           profiles is psick::primary_ip
# @param mgmt_interface # The management interface of the server.
# @param timezone The timezone to set on the system
#
# @example Sample data for proxy server hash
# psick::servers:
#   proxy:
#     host: proxy.example.com
#     port: 3128
#     user: john    # Optional
#     password: xxx # Optional
#     no_proxy:
#       - localhost
#       - "%{::domain}"
#     scheme: http
#
class psick (

  # General PSICK wide switches
  Boolean $manage = true,
  Boolean $auto_prereq = true,

  # Define auto_configuration layout to use
  Psick::Autoconf $auto_conf = 'none',

  # Firstrun mode. Disabled by default.
  Boolean $enable_firstrun = false,

  # General network settings
  Boolean $is_cluster = false,
  Optional[Stdlib::Compat::Ip_address] $primary_ip = $::networking['ip'],
  Optional[String] $mgmt_interface = $::networking['primary'],

  # An open hash of Psick wide settings. Define data structure and use as wanted
  Hash $settings = {},

  # An open hash of infrastructure endpoints. profile::proxy uses this
  Hash $servers = {},

  # Configure behaviour of tp in Psick. Look in data/ for defaults.
  Hash $tp = {},

  # Psick global firewall configurations. Look in data/ for defaults.
  Hash $firewall = {},

  # Psick global monitoring configurations. Look in data/ for defaults.
  Hash $monitor = {},

) {

  # RESOURCE DEFAULTS
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
  if $facts['firstrun'] == 'done' or $enable_firstrun == false {
    contain ::psick::pre
    contain ::psick::base
    contain ::psick::profiles
    Class['psick::pre'] -> Class['psick::base'] -> Class['psick::profiles']
  } else {
    contain ::psick::firstrun
    notify { "This catalog should be applied only at the first Puppen run\n": }
  }
}
