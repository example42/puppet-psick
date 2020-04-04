#
class psick::mongo (
  String                 $ensure           = 'present',
  Variant[Undef,String]  $key              = undef,
  String                 $replset          = '',
  Variant[Undef,String]  $default_password = undef,
  String                 $replset_arbiter  = '',
  Array                  $replset_members  = [],
  Variant[Undef,Boolean] $shardsvr         = undef,
  Variant[Undef,Hash]    $databases        = undef,
  Variant[Undef,Hash]    $hostnames        = undef,

  String                 $disable_huge_pages_class = 'psick::disable_huge_pages',
  String                 $mongo_class              = 'tp_profile::mongodb',
  String                 $mms_class                = '',

  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,

) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $disable_huge_pages_class != '' {
      contain $disable_huge_pages_class
      Class[$disable_huge_pages_class] -> Class[$mongo_class]
    }
    if $mongo_class != '' {
      contain $mongo_class
    }
    if $mms_class != '' {
      contain $mms_class
    }
  }
}
