# This class manages tp::test for PE Agents
#
class psick::puppet::pe_agent (
  Boolean $test_enable        = false,

  Boolean $manage_environment = false,
  String $environment_setting = $environment,

  Boolean $manage_noop        = false,
  Boolean $noop_setting       = false,

  Boolean $manage_service     = false,
  Enum['running','stopped'] $service_ensure = 'running',
  Boolean $service_enable     = true,

  Boolean $manage_exclude_unchanged_resources  = false,
  Boolean $exclude_unchanged_resources_setting = true,

  Hash $settings              = {},
  Hash $ini_settings_hash     = {},
  String $config_file_path    = '/etc/puppetlabs/puppet/puppet.conf',

  Boolean $manage             = $psick::manage,
  Boolean $noop_manage        = $psick::noop_manage,
  Boolean $noop_value         = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $test_enable {
      Tp::Test {
        cli_enable => true,
      }
      tp::test { 'puppet-agent': settings_hash => $settings }
    }

    # Manage Puppet agent service
    if $manage_service {
      service { 'puppet':
        ensure => $service_ensure,
        enable => $service_enable,
      }
      $service_notify = 'Service[puppet]'
    } else {
      $service_notify = undef
    }

    # Set environment
    if $manage_environment {
      pe_ini_setting { 'agent conf file environment':
        ensure  => present,
        path    => $config_file_path,
        section => 'agent',
        setting => 'environment',
        value   => $environment_setting,
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
        value   => $noop_setting,
        notify  => $service_notify,
      }
    }

    # Set exclude_unchanged_resources
    if $manage_exclude_unchanged_resources {
      pe_ini_setting { 'agent conf file exclude_unchanged_resources':
        ensure  => present,
        path    => $config_file_path,
        section => 'main',
        setting => 'exclude_unchanged_resources',
        value   => $exclude_unchanged_resources_setting,
        notify  => $service_notify,
      }
    }

    $default_ini_settings = {
      ensure  => present,
      path    => $config_file_path,
      notify  => $service_notify,
    }
    $ini_settings_hash.each | $k,$v | {
      $v.each | $kk,$vv | {
        $ini_settings = {
          section => $k,
          setting => $kk,
          value   => $vv,
        }
        pe_ini_setting { "puppet.conf ${k} - ${kk}":
          * => $default_ini_settings + $ini_settings,
        }
      }
    }
  }
}
