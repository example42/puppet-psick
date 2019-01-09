# @class psick::jenkins::jcasc
# @summary Installs and configures Jenkins Configuration as Code plugin
#
# @param ensure If the enable or not the plugin
# @param config_template Template to use for jenkins.yaml file
# @param options_hash Customn has of options to use for jenkins.yaml
# @param service_reload_command Command to execute to trigger Jenkins reload
class psick::jenkins::jcasc (
  Variant[Boolean,String] $ensure   = 'present',
  Optional[String] $config_template = undef,
  Optional[String] $config_path     = undef,
  Hash $options_hash                = {},
  String $jenkins_reload_command    = 'service jenkins force-reload',
) {

  if !defined(Psick::Jenkins::Plugin['configuration-as-code']) {
    $plugin_enable = $ensure ? {
      'absent' => false,
      default  => true,
    }
    psick::jenkins::plugin { 'configuration-as-code':
      enable   => $plugin_enable,
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
