# = Define: psick::php::module
#
# This define installs and configures php modules
# On Debian and derivatives it install module named php5-${name}
# On RedHat and derivatives it install module named php-${name}
# If you need a custom prefix you can overload default $module_prefix parameter
#
# == Parameters
#
# [*version*]
#   Version to install.
#
# [*absent*]
#   true to ensure package isn't installed.
#
# [*notify_service*]
#   If you want to restart a service automatically when
#   the module is applied. Default: true
#
# [*service_autorestart*]
#   whatever we want a module installation notify a service to restart.
#
# [*service*]
#   Service to restart.
#
# [*module_prefix*]
#   If package name prefix isn't standard.
#
# [*install_options*]
#   An array of package manager install options. See $php::install_options
#
# == Examples
# psick::php::module { 'gd': }
#
# psick::php::module { 'gd':
#   ensure => absent,
# }
#
# This will install php-apc on debian instead of php5-apc
#
# psick::php::module { 'apc':
#   module_prefix => "php-",
# }
#
# Note that you may include or declare the php class when using
# the psick::php::module define
#
define psick::php::module (
  Psick::Ensure $ensure = 'present',
  Hash $package_options = {},
  String $prefix        = '',
) {

  $real_module_prefix = $prefix ? {
    ''      => $psick::php::module_prefix,
    default => $prefix,
  }

  $package_name = "${real_module_prefix}${name}"
  $default_options = {
    ensure => $ensure,
  }

  if ! defined(Package[$package_name]) {
    package { $package_name:
      * => $default_options + $package_options,
    }
  }
}
