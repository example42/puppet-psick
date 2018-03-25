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

  Boolean $no_noop              = false,
) {

  if !$::psick::noop_mode and $no_noop {
    info('Forced no-noop mode.')
    noop(false)
  }

  file { '/etc/hosts':
    ensure  => file,
    content => template($template),
  }

}
