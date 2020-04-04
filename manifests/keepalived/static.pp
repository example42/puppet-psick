# Class to manage keepalived with static data
# Use psick::keepalived + psick::keepalived::balanced_host
# for dynamic management based on exported resurces
#
class psick::keepalived::static (
  Enum['present','absent'] $ensure                     = 'present',

  Variant[String[1],Undef] $config_dir_source          = undef,
  String                   $config_file_template       = 'psick/keepalived/keepalived.conf.erb',
  Boolean $manage                  = true,
  Boolean $noop_manage             = false,
  Boolean $noop_value              = false,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $options_default = {
      'notification_email_from' => "info@${::domain}",
      'smtp_server'             => 'localhost',
      'smtp_connect_timeout'    => '30',
      'lvs_id'                  =>  $::hostname,
    }

    $virtualservers=lookup('lb_virtualservers', Hash, 'deep', {} )
    $options_user=lookup('psick::keepalived::static::options', Hash, 'deep', {} )
    $options=merge($options_default,$options_user)

    ::tp::install { 'keepalived':
      ensure => $ensure,
    }

    if $config_file_template != '' {
      ::tp::conf { 'keepalived':
        ensure       => $ensure,
        template     => $config_file_template,
        options_hash => $options,
      }
    }

    ::tp::dir { 'keepalived::services':
      ensure => $ensure,
      path   => '/etc/keepalived/services',
      source => $config_dir_source,
    }

    $virtualservers.each | $vs , $params | {
      psick::keepalived::virtualserver_static { $vs:
        * => $params,
      }
    }
  }
}
