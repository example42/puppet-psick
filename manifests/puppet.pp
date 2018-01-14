class psick::puppet (

  String    $agent_class    = '::psick::puppet::tp',
  String    $server_class   = '',
  String    $puppetdb_class = '',

) {

  # This is the only PE related fact available also on clients
  if has_key($facts,'pe_concat_basedir') {
    notice('This module does not manage PE')
  } else {

    if $agent_class != '' {
      include $agent_class
    }
    if $server_class != '' {
      include $server_class
    }
    if $puppetdb_class != '' {
      include $puppetdb_class
    }
  }

}
