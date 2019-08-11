class psick::puppet (

  Optional[String] $agent_class    = undef,
  String           $server_class   = '',
  String           $puppetdb_class = '',

  Hash             $external_facts = {},

) {

  if has_key($facts,'pe_concat_basedir') {
    $real_agent_class = pick($agent_class, '::psick::puppet::pe_agent')
  } else {
    $real_agent_class = pick($agent_class, '::psick::puppet::tp')
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
