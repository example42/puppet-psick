# @class puppetdb
#
class psick::puppetdb (
  Optional[String]           $puppetdb_class   = 'tp_profile::puppetdb',
  Optional[String]           $postgresql_class = undef,


  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    if $puppetdb_class {
      contain $puppetdb_class
    }

    if $postgresql_class {
      contain $postgresql_class
      Class[$postgresql_class] -> Class[$puppetdb_class]
    }
  }
}
