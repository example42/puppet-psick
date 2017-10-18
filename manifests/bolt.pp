# @class bolt
#
class psick::bolt (

  Variant[Boolean,String] $ensure          = present,

  String                  $install_class   = '::psick::bolt::gem',
  String                  $user_class      = '::psick::bolt::user',
  String                  $master_class    = '::psick::bolt::master',
  String                  $node_class      = '::psick::bolt::node',

  String                  $user_name       = 'bolt',

  String                  $master          = '',
  Variant[Undef,String]   $keyshare_method = 'storeconfigs',

  Boolean                 $auto_prereq     = $::psick::auto_prereq,

  Boolean                 $is_master       = false,
  Boolean                 $is_node         = true,

) {

  if $user_name != 'bolt' {
    notify { 'Bolt user warning':
      message => 'If you change the default bolt user name change psick/facts.d/bolt_user_key.sh or set $::psick::bolt::master::ssh_key',
    }
  }

  if $install_class != '' and $is_master {
    contain $install_class
  }

  if $user_class != '' {
    contain $user_class
  }

  if $is_node {
    contain $node_class
  }

  if $is_master {
    contain $master_class
  }

}
