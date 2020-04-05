# @class psick::jenkins::jcasc
# @summary Installs and configures Jenkins Configuration as Code plugin
#
# @param ensure If the enable or not the plugin
# @param config_template Template to use for jenkins.yaml file
# @param options_hash Customn has of options to use for jenkins.yaml
# @param service_reload_command Command to execute to trigger Jenkins reload
class psick::jenkins::jcasc (
  Variant[Boolean,String] $ensure   = 'present',
  Array $plugins                    = [ 'configuration-as-code','configuration-as-code-support' ],
  Optional[String] $config_template = undef,
  Optional[String] $config_path     = undef,
  Hash $options_hash                = {},
  String $jenkins_reload_command    = 'service jenkins force-reload',
  Boolean $manage                   = $::psick::manage,
  Boolean $noop_manage              = $::psick::noop_manage,
  Boolean $noop_value               = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $plugin_enable = $ensure ? {
      'absent' => false,
      default  => true,
    }
    $plugins.each | $plugin | {
      if !defined(Psick::Jenkins::Plugin[$plugin]) {
        psick::jenkins::plugin { $plugin:
          enable   => $plugin_enable,
        }
      }
    }
    $real_config_path = pick($config_path,"${::psick::jenkins::home_dir}/jenkins.yaml")
    $options = $options_hash
    if $config_template {
      file { $real_config_path :
        ensure  => $ensure,
        mode    => '0644',
        owner   => 'jenkins',
        group   => 'jenkins',
        notify  => Service['jenkins'],
        replace => false,
        content => template($config_template),
        require => Package['jenkins'],
      }
    }
  }
}
