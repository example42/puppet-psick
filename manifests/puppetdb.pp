# @class puppetdb
#
class psick::puppetdb (
  Optional[String]           $puppetdb_class   = 'psick::puppetdb::tp',
  Optional[String]           $postgresql_class = undef,
) {

  if $puppetdb_class {
    contain $puppetdb_class
  }

  if $postgresql_class {
    contain $postgresql_class
    Class[$postgresql_class] -> Class[$puppetdb_class]
  }

}
