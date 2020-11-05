# This class manages tp::test for PE server and additional resources
# to complement the official puppet_enterprise::master class.
#
class psick::puppet::pe_server (
  Boolean $remove_global_hiera_yaml  = false,
  String  $extra_environment_path    = '',
  Hash    $extra_environment_files   = {},
  Boolean $manage                    = $::psick::manage,
  Boolean $noop_manage               = $::psick::noop_manage,
  Boolean $noop_value                = $::psick::noop_value,
  Hash    $extra_authorization_rules = {},
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $extra_environment_path != '' {
      pe_ini_setting { 'master conf environmentpath':
        ensure  => present,
        path    => '/etc/puppetlabs/puppet/puppet.conf',
        section => 'master',
        setting => 'environmentpath',
        value   => "/etc/puppetlabs/code/environments:${extra_environment_path}",
        notify  => Service['pe-puppetserver'],
      }
      file { $extra_environment_path:
        ensure => directory,
        owner  => 'pe-puppet',
        group  => 'pe-puppet',
      }
      $extra_environment_files.each | $k,$v | {
        file { "${extra_environment_path}/${k}":
          * => $v,
        }
      }
    }
    if $remove_global_hiera_yaml {
      file { '/etc/puppetlabs/puppet/hiera.yaml':
        ensure => absent,
      }
    }

    Pe_puppet_authorization::Rule {
      path    => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
      require => Pe_puppet_authorization['/etc/puppetlabs/puppetserver/conf.d/auth.conf'],
      notify  => Service['pe-puppetserver'],
    }

    $extra_authorization_rules.each | $k,$v | {
      pe_puppet_authorization::rule { $k:
        * => $v,
      }
    }

    Tp::Test {
      cli_enable => true,
      content    => 'puppet infrastructure status',
    }
    $puppetserver_settings = {
      package_name => 'pe-puppetserver',
      service_name => 'pe-puppetserver',
    }
    tp::test { 'puppetserver': settings_hash => $puppetserver_settings }
  }
}
