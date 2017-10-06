# @class ansible
#
class psick::ansible (

  Variant[Boolean,String] $ensure          = present,

  String                  $install_class   = '::psick::ansible::tp',
  String                  $user_class      = '::psick::ansible::user',
  String                  $master_class    = '::psick::ansible::master',
  String                  $node_class      = '::psick::ansible::node',

  String                  $user_name       = 'ansible',

  String                  $master          = '',
  String                  $ssh_key         = '',
  Variant[Undef,String]   $keyshare_method = '',

  Boolean                 $auto_prereq     = $::psick::auto_prereq,

  Boolean                 $is_master       = false,
  Boolean                 $is_node         = true,

) {

  if ::tp::is_something($install_class) {
    contain $install_class
  }

  if ::tp::is_something($user_class) {
    contain $user_class
  }

  if $is_node {
    contain $node_class
  }

  if $is_master {
    contain $master_class
  }

}
