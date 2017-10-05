# This class manages tp::test for PE server
#
class psick::puppet::pe_server (
  Boolean $remove_global_hiera_yaml = false,
) {

  if $remove_global_hiera_yaml {
    file { '/etc/puppetlabs/puppet/hiera.yaml':
      ensure => absent,
    }
  }
  $puppetserver_settings = {
    package_name => 'pe-puppetserver',
    service_name => 'pe-puppetserver',
  }

  Tp::Test {
    cli_enable => true,
    template   => '',
  }
  tp::test { 'puppetserver': settings_hash => $puppetserver_settings }

}
