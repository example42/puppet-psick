# @class ansible
#
class psick::ansible (

  Variant[Boolean,String] $ensure          = present,

  String                  $install_class   = '::tp_profile::ansible',
  String                  $user_class      = '::psick::ansible::user',
  String                  $master_class    = '::psick::ansible::master',
  String                  $node_class      = '::psick::ansible::node',

  String                  $user_name       = 'ansible',

  String                  $master          = '',
  Variant[Undef,String]   $keyshare_method = 'storeconfigs',

  Boolean                 $auto_prereq     = $::psick::auto_prereq,

  Boolean                 $is_master       = false,
  Boolean                 $is_node         = true,

  Boolean                 $manage          = $::psick::manage,
  Boolean                 $noop_manage     = $::psick::noop_manage,
  Boolean                 $noop_value      = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $user_name != 'ansible' {
      notify { 'Ansible user warning':
        message => 'If you change the default ansible user name change psick/facts.d/ansible_user_key.sh or set $::psick::ansible::master::ssh_key', # lint:ignore:140chars
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
}
