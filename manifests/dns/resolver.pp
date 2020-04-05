# This class manages /etc/resolv.conf
# Based on ghoneycutt-dnsclient
class psick::dns::resolver (
  Array $nameservers           = ['8.8.8.8','8.8.4.4'],
  Optional[Array] $options     = undef,
  Optional[Array] $search      = undef,
  Optional[String] $domain     = undef,
  Optional[Array] $sortlist    = undef,
  String $resolver_path        = '/etc/resolv.conf',
  String $resolver_template    = 'psick/dns/resolver/resolv.conf.erb',

  Boolean $manage              = $::psick::manage,
  Boolean $noop_manage         = $::psick::noop_manage,
  Boolean $noop_value          = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $::virtual != 'docker' {
      file { $resolver_path:
        ensure  => file,
        content => template($resolver_template),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
      }
    }
  }
}
