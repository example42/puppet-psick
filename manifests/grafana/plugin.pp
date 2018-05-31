# This define manages Grafana plugins
#
# @param ensure To install or remove a plugin
# @param version If to installa a specific version of a plugin
# @param plugin The name of the plugin to install, by default the
#   $title of this define is used
# @param exec_notify What and if to notify a resource after
#   plugin installation. By default grafana.server service is
#   restarted.
#
# @example Usage via hiera data and the psick::grafana class
#    psick::grafana::plugins_hash:
#      cloudflare-app: {}
#      raintank-worldping-app: {}
#
define psick::grafana::plugin (
  Enum['present','absent'] $ensure = 'present',
  String $version                  = ' ',
  String $plugin                   = $title,
  Optional[String] $exec_notify    = 'Service[grafana-server]',
  Optional[String] $exec_require   = 'Package[grafana]',
) {

  if $ensure == 'present' {
    exec { "grafana plugins install ${plugin}":
      command => "grafana-cli plugins install ${plugin} ${version}",
      unless  => "grafana-cli plugins ls | grep ${plugin} | grep '${version}'",
      notify  => $exec_notify,
      require => $exec_require,
      path    => $::path,
    }
  } else {
    exec { "grafana plugins uninstall ${plugin}":
      command => "grafana-cli plugins uninstall ${plugin}",
      onlyif  => "grafana-cli plugins ls | grep ${plugin}",
      notify  => $exec_notify,
      require => $exec_require,
      path    => $::path,
    }
  }
}
