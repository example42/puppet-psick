# This class manages tp::test for PE Agents
#
class psick::puppet::pe_agent (
  Boolean $test_enable        = false,
  Boolean $manage_environment = false,
  Boolean $manage_noop        = false,
  Boolean $manage_service     = false,
  Boolean $noop_mode          = false,
  Hash $settings              = {},
  String $config_file_path    = '/etc/puppetlabs/puppet/puppet.conf',

  Boolean $no_noop            = false,
) {

  if !$::psick::noop_mode and $no_noop {
    info('Forced no-noop mode.')
    noop(false)
  }

  if $test_enable {
    Tp::Test {
      cli_enable => true,
      template   => '',
    }
    tp::test { 'puppet-agent': settings_hash => $settings }
  }

  # Manage Puppet agent service
  if $manage_service {
    service { 'puppet':
      ensure => 'running',
      enable => true,
    }
    $service_notify = 'Service[puppet]'
  } else {
    $service_notify = undef
  }

  # Set environment
  if $manage_environment {
    ini_setting { 'agent conf file environment':
      ensure  => present,
      path    => $config_file_path,
      section => 'agent',
      setting => 'environment',
      value   => $environment,
      notify  => $service_notify,
    }
  }

  # Set noop mode
  if $manage_noop {
    pe_ini_setting { 'agent conf file noop':
      ensure  => present,
      path    => $config_file_path,
      section => 'agent',
      setting => 'noop',
      value   => $noop_mode,
      notify  => $service_notify,
    }
  }
}
