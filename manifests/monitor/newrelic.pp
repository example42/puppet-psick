# == Class: site::monitor::newrelic
#
class psick::monitor::newrelic (
  $ensure                     = 'present',

  $config_dir_source          = undef,
  $config_file_template       = 'psick/monitor/newrelic/nrsysmond.cfg.erb',
  $extra_config_file_template = undef,
  Boolean $manage             = $::psick::manage,
  Boolean $noop_manage        = $::psick::noop_manage,
  Boolean $noop_value         = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    $options_default = {
      license_key => 'CHANGEME',
      proxy       => $::psick::http_proxy,
    }
    #
    $options_user=lookup('newrelic_options', Hash, 'deep', {} )
    $options=merge($options_default,$options_user)

    ::tp::install { 'newrelic':
      ensure => $ensure,
    }
    ::tp::dir { 'newrelic':
      ensure => $ensure,
      source => $config_dir_source,
    }
    ::tp::conf { 'newrelic':
      ensure       => $ensure,
      template     => $config_file_template,
      options_hash => $options,
    }

    ::tp::conf { 'newrelic::extra.conf':
      ensure       => $ensure,
      template     => $extra_config_file_template,
      options_hash => $options,
    }
  }
}
