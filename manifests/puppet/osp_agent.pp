# This class manages Open Source Puppet Agent
#
class psick::puppet::osp_agent (
  Boolean $manage_installation = true,
  Hash $tp_params              = {},

  Boolean $cronjob_ensure     = 'absent',
  String $cronjob_schedule    = '0,30 * * * *',

  Boolean                   $manage_service = true,
  Enum['running','stopped'] $service_ensure = 'running',

  Hash $settings              = {},
  String $config_template     = 'psick/generic/inifile_with_stanzas.erb',

  Boolean $manage             = $::psick::manage,
  Boolean $noop_manage        = $::psick::noop_manage,
  Boolean $noop_value         = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    # Manage Puppet agent service
    if $manage_installation {
      $local_params = {
        'settings_hash' => {
          service_ensure => $service_ensure,
        },
        manage_service => $manage_service,
      }
      tp::install { 'puppet-agent':
        * => $local_params + $tp_params,
      }
    }

    if $settings != {} {
      tp::conf { 'puppet-agent':
        content => psick::template($config_template),
      }
    }

    file { '/etc/cron.d/puppet-agent':
      ensure  => $cronjob_ensure,
      content => "PATH=/opt/puppetlabs/puppet/bin:/usr/sbin:/usr/bin\n${cronjob_schedule} root puppet agent -t"
    }
  }
}
