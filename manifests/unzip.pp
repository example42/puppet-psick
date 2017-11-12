# @summary Installs unzip
#
# @param ensure if to install unzip
#
class psick::unzip (
  String $ensure        = 'present',
) {
  package { 'unzip':
    ensure => $ensure,
  }
}
