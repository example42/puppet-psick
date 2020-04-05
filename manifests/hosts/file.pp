# This class manages the content of the /etc/hosts file
#
# @param template The erb template to use to manage the content of /etc/hosts
# @param ipaddress The IP address to use for the node hostname
# @param domain the domain to use for the node domain name
# @param hostname The hostname to use for the node hostname
# @param extra_hosts An array of extra lines to add (one line for array element)
#                    to /etc/hosts.
#
class psick::hosts::file (
  String $template  = 'psick/hosts/file/hosts.erb',

  Optional[Stdlib::Compat::Ip_address] $ipaddress = $::psick::primary_ip,
  Variant[Undef,String] $domain = $::domain,
  String $hostname              = $::hostname,
  Array $extra_hosts            = [],

  Boolean $manage               = $::psick::manage,
  Boolean $noop_manage          = $::psick::noop_manage,
  Boolean $noop_value           = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    file { '/etc/hosts':
      ensure  => file,
      content => template($template),
    }
  }
}
