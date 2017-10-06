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
  Variant[Undef,String]   $keyshare_method = 'storeconfigs',

  Boolean                 $auto_prereq     = $::psick::auto_prereq,

  Boolean                 $is_master       = false,
  Boolean                 $is_node         = true,

) {

  if $user_name != 'ansible' {
    notify { 'Ansible user warning':
      message => 'If you change the default ansible user name change psick/facts.d/ansible_user_key.sh or set $::psick::ansible::master::ssh_key',
    }
  }

  if $install_class != '' {
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
