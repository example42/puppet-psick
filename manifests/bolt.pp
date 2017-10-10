# This class installs and configures bolt.
#
# @param ensure Define if to install (present), remote (absent) bolt gem
#
class psick::bolt (
  String $ensure               = 'present',
) {
  contain ::psick::ruby

  package { 'bolt':
    ensure   => $ensure,
    provider => 'gem',
    require  => Class['psick::ruby'],
  }
}
