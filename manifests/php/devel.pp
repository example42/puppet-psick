# Class: psick::php::devel
#
# @summary Installs php devel packages
#
# This class installs php devel package.
#
# @param package Name of the package to install.
#
# @param ensure Ensure parameter for the package to install.
#
# @param package_options An hash to pass to the package resource
#    for special installation needs.
#
class psick::php::devel (
  Psick::Ensure $ensure = 'present',
  String $package       = 'php-devel',
  Hash $package_options = {},
  Boolean $manage       = $psick::manage,
  Boolean $noop_manage  = $psick::noop_manage,
  Boolean $noop_value   = $psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    $default_options = {
      ensure          => $ensure,
    }
    package { $package:
      * => $default_options + $package_options,
    }
  }
}
