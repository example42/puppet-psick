# @summary This class installs and manages php-fpm
#
# @example
#   include psick::php::fpm
class psick::php::fpm (

  Psick::Ensure $ensure = 'present',

  String $package_name  = 'php-fpm',
  Hash $package_params  = {},

  String $service_name  = 'php-fpm',
  Hash $service_params  = {},

  Hash $files_hash      = {},
  Hash $options_hash    = {},

  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    # Package
    $package_defaults = {
      ensure => $ensure,
    }
    package { $package_name:
      * => $package_defaults + $package_params,
    }

    # Service
    $service_defaults = {
      ensure => psick::ensure2service($ensure,'ensure'),
      enable => psick::ensure2service($ensure,'enable'),
    }
    service { $service_name:
      * => $service_defaults + $service_params,
    }

    # Configuration files
    $file_defaults = {
      ensure  => $ensure,
      require => Package[$package_name],
      notify  => Service[$service_name],
    }
    $files_hash.each |$k,$v| {
      file { $k:
        * => $file_defaults + $v,
      }
    }
  }
}
