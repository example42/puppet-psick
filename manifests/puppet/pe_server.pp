# This class manages tp::test for PE server
#
class psick::puppet::pe_server (
  Boolean $remove_global_hiera_yaml = false,
  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

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
      content    => 'puppet infrastructure status',
    }
    tp::test { 'puppetserver': settings_hash => $puppetserver_settings }
  }
}
