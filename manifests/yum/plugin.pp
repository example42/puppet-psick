# Define: psick::yum::plugin
#
define psick::yum::plugin (
  String $package_name            = '', # lint:ignore:params_empty_string_assignment
  String $source                  = '', # lint:ignore:params_empty_string_assignment
  Variant[String,Undef] $template = '', # lint:ignore:params_empty_string_assignment
  Boolean $enable                 = true
) {
  $ensure = bool2ensure( $enable )

  $yum_plugins_prefix = $facts['os']['release']['major'] ? {
    '5'     => 'yum',
    '6'     => 'yum-plugin',
    default => 'yum-plugin',
  }

  $real_package_name = $package_name ? {
    ''      => "${yum_plugins_prefix}-${name}",
    default => $package_name,
  }

  package { $real_package_name :
    ensure => $ensure,
  }

  if ( $source != '' ) {
    file { "yum_plugin_conf_${name}":
      ensure => $ensure,
      path   => "${yum::plugins_config_dir}/${name}.conf",
      owner  => root,
      group  => root,
      mode   => '0644',
      source => $source,
    }
  }
}
