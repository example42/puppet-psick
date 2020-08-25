#
class psick::puppet (

  Optional[String] $agent_class    = undef,
  String           $server_class   = '',
  String           $puppetdb_class = '',

  Hash             $external_facts = {},

  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
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
  }
}
