# This define manages Grafana dashboard
#
#
# @example Usage via hiera data and the psick::grafana class
#
#     psick::grafana::dashboards_hash:
#       default:
#         ensure: present
#         type: 'file'
#         org_id: '1'
#         editable: 'false'
#         disable_deletion: 'true'
#         options:
#           path: '/var/lib/grafana/dashboards'
#

define psick::grafana::dashboard (
  Enum['present','absent'] 
                    $ensure        = 'present',
  String            $template      = 'psick/grafana/dashboard.yaml.erb',
  String  $org_id                  = '1',
  String  $folder                  = '',
  String  $type                    = 'file',
  Enum['true', 'false'] 
          $disable_deletion        = 'false',
  Enum['true', 'false'] 
          $editable                = 'false',
  Hash    $options                 = {},
  Optional[String]  $exec_notify   = 'Service[grafana-server]',
  
) {

  file { "/etc/grafana/provisioning/dashboards/${name}.yaml":
    content => template($template), 
    notify  => $exec_notify,
  }
  
}
