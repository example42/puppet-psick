# @summary This class installs and manages php-fpm
#
# @example
#   include psick::php::fpm
class psick::php::fpm (

  Psick::Ensure $ensure = 'present',

  Boolean $manage       = $::psick::manage,

  String $package_name  = 'php-fpm',
  Hash $package_params  = {},

  String $service_name  = 'php-fpm',
  Hash $service_params  = {},

  Hash $files_hash      = {},
  Hash $options_hash    = {},
  
  Boolean $no_noop      = false,

) {

  if $manage {
    if !$::psick::noop_mode and $no_noop {
      info('Forced no-noop mode in psick::jenkins::tp')
      noop(false)
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
