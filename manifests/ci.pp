# Manages /etc/ci.conf file, used by CI scripts under bin
#
class psick::ci (
  String                $ensure           = 'present',
  String                $config_file_path = '/etc/ci.conf',
  Variant[Undef,String] $template         = 'psick/ci/ci.conf.erb',
  Hash                  $options          = { },
  Array                 $default_nodes    = [],
  Array                 $always_nodes     = [],
) {

  $options_default = {
    catalog_diff_default_nodes => pick(join($default_nodes,','),' '),
    catalog_preview_default_nodes => pick(join($default_nodes,','),' '),
    tp_test_default_nodes => pick(join($default_nodes,','),' '),
    testing_query_default_nodes => pick(join($default_nodes,','),' '),
    integration_query_default_nodes => pick(join($default_nodes,','),' '),
    production_query_default_nodes => pick(join($default_nodes,','),' '),

    catalog_diff_always_nodes => pick(join($always_nodes,','),' '),
    catalog_preview_always_nodes => pick(join($always_nodes,','),' '),
    tp_test_always_nodes => pick(join($always_nodes,','),' '),
    testing_query_always_nodes => pick(join($always_nodes,','),' '),
    integration_query_always_nodes => pick(join($always_nodes,','),' '),
    production_query_always_nodes => pick(join($always_nodes,','),' '),
  }
  $ci_options = $options_default + $options
  file { $config_file_path:
    ensure  => $ensure ,
    content => template($template),
  }
}
