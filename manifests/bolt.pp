# @class bolt
#
class psick::bolt (

  Variant[Boolean,String] $ensure          = present,

  String                  $master_class    = 'psick::bolt::master',
  String                  $node_class      = 'psick::bolt::node',

  String                  $bolt_user          = 'bolt',
  String                  $bolt_group         = 'bolt',
  Optional[String]        $bolt_user_pub_key  = undef,
  Optional[String]        $bolt_user_priv_key = undef,

  String                  $ssh_user           = 'root',
  String                  $ssh_group          = 'root',

  String                  $master             = '', # lint:ignore:params_empty_string_assignment
  Enum['storeconfigs','static'] $keyshare_method = 'storeconfigs',

  Boolean                 $manage_host_key     = true,

  Boolean                 $auto_prereq        = $psick::auto_prereq,

  Boolean                 $is_master          = false,
  Boolean                 $is_node            = true,

  Hash                    $projects_hash      = {},

  Boolean                 $manage             = $psick::manage,
  Boolean                 $noop_manage        = $psick::noop_manage,
  Boolean                 $noop_value         = $psick::noop_value,

) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $is_node {
      contain $node_class
    }

    if $is_master {
      contain $master_class
    }

    $projects_hash.each | $k,$v | {
      psick::bolt::project { $k:
        * => $v,
      }
    }
  }
}
