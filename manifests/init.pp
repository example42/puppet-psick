# Class used as entry point to set general settings used by other psick profiles
#
# @param is_cluster Defines if the server is a cluster member
# @param primary_ip_address The server primary IP address. Default value is
#                           automatically calculated based on the mgmt_interface
#                           address. The resulting variable, used in other
#                           profiles is psick::primary_ip
# @param mgmt_interface # The management interface of the server.
# @param timezone The timezone to set on the system
# @param proxy_server An hash describing the proxy server to use. This data is
#                     used by psick::proxy and any other class which needs
#                     proxy information
#
# @example Sample data for proxy server hash
# psick::proxy_server:
#   host: proxy.example.com
#   port: 3128
#   user: john    # Optional
#   password: xxx # Optional
#   no_proxy:
#     - localhost
#     - "%{::domain}"
#   scheme: http
#
class psick (

  # General PSICK wide switches
  Boolean $manage,
  Boolean $auto_conf,

  # Firstrun mode. Disabled by default.
  Hash $firstrun              = {},

  # General network settings
  Boolean $is_cluster         = false,
  Stdlib::Compat::Ip_address $primary_ip_address = '255.255.255.255',
  String  $mgmt_interface     = $facts['networking']['primary'],
  Optional[String] $timezone  = '',

  # PSICK wide settings
  Hash $settings              = {},
  Hash $servers               = {},
  Hash $tp                    = {},
  Hash $firewall              = {},
  Hash $monitor               = {},

) {

  # PSICK VARIABLES
  $primary_ip = $primary_ip_address ? {
    '255.255.255.255' => $facts['networking']['interfaces'][$mgmt_interface]['ip'],
    default           => $primary_ip_address,
  }

  # RESOURCE DEFAULTS
  Tp::Install {
    cli_enable   => $tp['cli_enable'],
    test_enable  => $tp['test_enable'],
    puppi_enable => $tp['puppi_enable'],
    debug        => $tp['debug'],
    data_module  => $tp['data_module'],
  }
  Tp::Conf {
    config_file_notify => $tp['config_file_notify'],
    config_file_require => $tp['config_file_require'],
    debug        => $tp['debug'],
    data_module  => $tp['data_module'],
  }
  Tp::Dir {
    config_dir_notify => $tp['config_dir_notify'],
    config_dir_require => $tp['config_dir_require'],
    debug        => $tp['debug'],
    data_module  => $tp['data_module'],
  }

  # PSICK PROFILES
  if $firstrun['enable'] and lookupvar($firstrun['fact_name']) == $firstrun['fact_value'] {
    $kernel_down=downcase($::kernel)
    contain "::psick::${kernel_down}"

  } else {
    contain "::psick::firstrun::${kernel_down}"
    notify { "This catalog should be applied only at the first Puppen run\n": }
  }
}
