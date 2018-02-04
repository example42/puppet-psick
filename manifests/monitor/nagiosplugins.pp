# This class installs Nagios plugins using tp
#
class psick::monitor::nagiosplugins (
  Variant[Boolean,String] $ensure = present,
  Boolean     $auto_prereq = true,
) {

  ::tp::install { 'nagios-plugins':
    ensure             => $ensure,
    auto_prereq => $auto_prereq,
  }

}
