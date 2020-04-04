# Wrapper class to install Oracle components
#
class psick::oracle::install (
  Optional[String] $install_db_class       = '::psick::oracle::install::db',
  Optional[String] $install_em_class       = undef,
  Optional[String] $install_dbclient_class = undef,
  Optional[String] $install_grid_class     = undef,
  Boolean $manage                          = $::psick::manage,
  Boolean $noop_manage                     = $::psick::noop_manage,
  Boolean $noop_value                      = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    if $install_db_class and $install_db_class != '' {
      contain $install_db_class
    }
    if $install_em_class and $install_em_class != '' {
      contain $install_em_class
    }
    if $install_dbclient_class and $install_dbclient_class != '' {
      contain $install_dbclient_class
    }
    if $install_grid_class and $install_grid_class != '' {
      contain $install_grid_class
    }
  }
}
