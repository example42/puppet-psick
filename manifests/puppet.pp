#
class psick::puppet (

  Optional[String] $agent_class     = undef,
  String           $server_class    = '', # lint:ignore:params_empty_string_assignment
  String           $puppetdb_class  = '', # lint:ignore:params_empty_string_assignment

  Array $modules                    = [],
  String $module_user               = 'root',

  Hash             $external_facts  = {},

  String           $facts_file_path = '', # lint:ignore:params_empty_string_assignment
  Regexp           $facts_file_exclude_regex = /^(.*uptime.*|system_uptime|_timestamp|memoryfree.*|swapfree.*|puppet_inventory_metadata|last_run.*|load_averages.*|memory.*|mountpoints.*|physical_volumes.*|volume_groups.*)$/, # lint:ignore:140chars

  Boolean          $manage               = $psick::manage,
  Boolean          $noop_manage          = $psick::noop_manage,
  Boolean          $noop_value           = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    if $facts['pe_concat_basedir'] == '/opt/puppetlabs/puppet/cache/pe_concat' {
      $real_agent_class = pick($agent_class, '::psick::puppet::pe_agent')
    } else {
      $real_agent_class = pick($agent_class, '::psick::puppet::osp_agent')
    }

    if $agent_class != '' {
      include $real_agent_class
    }
    if $server_class != '' {
      include $server_class
    }
    if $puppetdb_class != '' {
      include $puppetdb_class
    }

    $external_facts.each | $k , $v | {
      psick::puppet::set_external_fact { $k:
        * => $v,
      }
    }

    if $facts_file_path != '' {
      file { $facts_file_path:
        content => template('psick/puppet/facts.yaml.erb'),
      }
    }

    $modules.each | $mod | {
      psick::puppet::module { $mod:
        user   => $module_user,
      }
    }
  }
}
