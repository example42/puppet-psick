# @class bolt
#
class psick::bolt (

  Variant[Boolean,String] $ensure          = present,

  String                  $master_class    = '::psick::bolt::master',
  String                  $node_class      = '::psick::bolt::node',

  String                  $bolt_user          = 'bolt',
  Optional[String]        $bolt_user_pub_key  = undef,
  Optional[String]        $bolt_user_priv_key = undef,

  String                  $ssh_user           = 'root',

  String                  $master          = '',
  Optional[Enum['storeconfigs','static']] $keyshare_method = 'storeconfigs',

  Boolean                 $auto_prereq     = $::psick::auto_prereq,

  Boolean                 $is_master       = false,
  Boolean                 $is_node         = true,

) {

  if $is_node {
    contain $node_class
  }

  if $is_master {
    contain $master_class
  }

}
