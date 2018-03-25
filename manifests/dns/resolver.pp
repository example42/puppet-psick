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

  Boolean $no_noop             = false,
) {

  if !$::psick::noop_mode and $no_noop {
    info('Forced no-noop mode.')
    noop(false)
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
