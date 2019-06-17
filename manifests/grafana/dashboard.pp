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
  Enum['true', 'false']                         # lint:ignore:quoted_booleans
          $disable_deletion        = 'false',   # lint:ignore:quoted_booleans
  Enum['true', 'false']                         # lint:ignore:quoted_booleans
          $editable                = 'false',   # lint:ignore:quoted_booleans
  Hash    $options                 = {},

) {

  tp::conf { "grafana::${name}.yaml":
    content  => template($template),
    base_dir => 'dashboards',
  }

}
