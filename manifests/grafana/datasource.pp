# This define manages Grafana datasource
#
# @param ensure To configure datasource
# @param name name of the datasource. Required 
#   $title of this define is used
# @param type datasource type. Required
# @param proxy access mode. direct or proxy. Required
#
#
# @example Usage via hiera data and the psick::grafana class
#
#    psick::grafana::datasources_hash:
#      InfluxDB:
#        type: influxdb
#        access: proxy
#        database: site
#        user: grafana
#        password: grafana
#        url: http://localhost:8086
#
define psick::grafana::datasource (
  Enum['present','absent'] 
                    $ensure        = 'present',
  String            $template      = 'psick/grafana/datasource.yaml.erb',
  String            $type,
  String            $access,
  Optional[String]  $org_id             = undef,
  Optional[String]  $url                = undef,
  Optional[String]  $database           = undef,
  Optional[String]  $user               = undef,
  Optional[String]  $password           = undef,
  Optional[String]  $basic_auth         = undef,
  Optional[String]  $basic_authUser     = undef,
  Optional[String]  $basic_authPassword = undef,
  Optional[Boolean] $with_credentials   = undef,
  Optional[Boolean] $is_default         = undef,
  Optional[Hash]    $json_data          = undef,
  Optional[Hash]    $secure_json_data   = undef,
  Optional[Boolean] $editable           = undef,
  Optional[String]  $exec_notify        = 'Service[grafana-server]',
  
) {

  file { "/etc/grafana/provisioning/datasources/${name}.yaml":
    content => template($template), 
    notify  => $exec_notify,
  }
  
}
