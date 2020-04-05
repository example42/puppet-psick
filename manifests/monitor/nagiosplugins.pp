# This class installs Nagios plugins using tp
#
class psick::monitor::nagiosplugins (
  Variant[Boolean,String] $ensure = present,
  Boolean $auto_prereq            = $::psick::auto_prereq,
  Boolean $manage                 = $::psick::manage,
  Boolean $noop_manage            = $::psick::noop_manage,
  Boolean $noop_value             = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    ::tp::install { 'nagios-plugins':
      ensure      => $ensure,
      auto_prereq => $auto_prereq,
    }
  }
}
