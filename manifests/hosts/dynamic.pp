# ::psick::hosts::dynamic
# Derived from https://github.com/example42/puppet-hosts
# Manage /etc/hosts dynamically. Requires puppetdb
#
class psick::hosts::dynamic (
  String $dynamic_magicvar = '',
  Boolean $dynamic_exclude = false,
  String  $dynamic_ip      = $::ipaddress,
  Array  $dynamic_alias    = [ $::hostname ],
  Hash  $extra_hosts       = { },
  Boolean $manage          = $::psick::manage,
  Boolean $noop_manage     = $::psick::noop_manage,
  Boolean $noop_value      = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    $magic_tag = get_magicvar($dynamic_magicvar)

    $real_tag = $dynamic_exclude ? {
      true    => 'Excluded',
      default => "env-${magic_tag}",
    }

    @@host { $::fqdn:
      ip           => $hosts::dynamic_ip,
      host_aliases => $hosts::dynamic_alias,
      tag          => $real_tag,
    }

    Host <<| tag == "env-${magic_tag}" |>> {
      ensure  => present,
    }

    if $extra_hosts != {} {
      $extra_hosts.each | $k,$v | {
        host { $k:
          * => $v,
        }
      }
    }
  }
}
