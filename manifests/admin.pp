# This class manages an admin user and SSH access on Puppet managed nodes.
#
# == Parameters
#
# [*ensure*]
#   Whether the admin user should be present or absent. Defaults to `present`.
#
# [*user_class*]
#   The name of the class that manages the admin user on infrastructure nodes. Defaults to `::psick::admin::user`.
#   Note: If default is changed other params of this class might not be used.
#
# [*master_class*]
#   The name of the class that manages the central master node from which ssh access is granted. Defaults to `::psick::admin::master`.
#   Note: If default is changed other params of this class might not be used.
#
# [*node_class*]
#   The name of the class that manages nodes which allow access from master node. Defaults to `::psick::admin::node`.
#   Note: If default is changed other params of this class might not be used.
#
# [*user*]
#   The name of the admin user. Defaults to `admin`.
#
# [*master*]
#   The hostname or IP address of the master node. Defaults to `''`.
#
# [*keyshare_method*]
#   The method used to share SSH keys between nodes and the master node. Defaults to `storeconfigs`.
#
# [*auto_prereq*]
#   Whether to automatically include prerequisite classes. Defaults to the value of `$psick::auto_prereq`.
#
# [*master_enable*]
#   Whether to enable master management. If true, master class is included and node is a master. Defaults to `false`.
#
# [*node_enable*]
#   Whether to enable node management. If true, node class is included and node can bve controlled from master. Defaults to `true`.
#
# [*manage*]
#   Whether to manage any resource on this class. Defaults to the value of `$psick::manage`.
#
# [*noop_manage*]
#   Whether to manage noop for this class resources. Defaults to the value of `$psick::noop_manage`.
#
# [*noop_value*]
#   The value to use for noop mode. Defaults to the value of `$psick::noop_value`.
#
# == Example
#
# To manage the admin user and SSH access from master node, just include the `psick::admin` class:
#
#     include psick::admin
#
# Via Hiera on the master node set:
#
#     psick::admin::master_enable: true
#
class psick::admin (

  Variant[Boolean,String] $ensure          = present,

  String                  $user_class      = '::psick::admin::user',
  String                  $master_class    = '::psick::admin::master',
  String                  $node_class      = '::psick::admin::node',

  String                  $user            = 'admin',

  String                  $master          = '', # lint:ignore:params_empty_string_assignment
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

    if $user != 'admin' {
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
