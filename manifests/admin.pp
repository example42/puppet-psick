# @class admin
#
class psick::admin (

  Variant[Boolean,String] $ensure          = present,

  String                  $user_class      = '::psick::admin::user',
  String                  $master_class    = '::psick::admin::master',
  String                  $node_class      = '::psick::admin::node',

  String                  $user_name       = 'admin',

  String                  $master          = '',
  Variant[Undef,String]   $keyshare_method = 'storeconfigs',

  Boolean                 $auto_prereq     = $psick::auto_prereq,

  Boolean                 $master_enable   = false,
  Boolean                 $node_enable     = true,

  Boolean                 $manage          = $psick::manage,
  Boolean                 $noop_manage     = $psick::noop_manage,
  Boolean                 $noop_value      = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $user_name != 'admin' {
      notify { 'admin user warning':
        message => 'If you change the default admin user name change psick/facts.d/admin_user_key.sh or set $::psick::admin::master::ssh_key', # lint:ignore:140chars
      }
    }

    if $user_class != '' {
      contain $user_class
    }

    if $node_enable {
      contain $node_class
    }

    if $master_enable {
      contain $master_class
    }
  }
}
