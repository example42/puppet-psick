# Define: psick::php::pear::module
#
# Installs the defined php pear component
#
# Variables:
# [*use_package*]
#   (default=true) - Tries to install pear module with the relevant OS package
#   If set to "no" it installs the module via pear command
#
# [*install_options*]
#   An array of package manager install options. See $psick::php::install_options
#
# [*preferred_state*]
#   (default="stable") - Define which preferred state to use when installing
#   Pear modules via pear via command line (when use_package=false)
#
# [*alldeps*]
#   (default="false") - Define if all the available (optional) modules should
#   be installed. (when use_package=false)
#
# Usage:
# psick::php::pear::module { packagename: }
# Example:
# psick::php::pear::module { Crypt-CHAP: }
#
define psick::php::pear::module (
  String $service              = '', # lint:ignore:params_empty_string_assignment
  Boolean $use_package         = true,
  Array $install_options       = [],
  String $preferred_state      = 'stable',
  Boolean $alldeps             = false,
  String $version              = 'present',
  String $repository           = 'pear.php.net',
  Boolean $service_autorestart = false,
  String $module_prefix        = '', # lint:ignore:params_empty_string_assignment
  String $path                 = '/usr/bin:/usr/sbin:/bin:/sbin',
  String $ensure               = 'present',
  Integer $timeout             = 300
) {
  include psick::php::pear

  $bool_use_package = any2bool($use_package)
  $bool_alldeps = any2bool($alldeps)
  $manage_alldeps = $bool_alldeps ? {
    true  => '--alldeps',
    false => '',
  }

  $pear_source = $version ? {
    'present' => "${repository}/${name}",
    default   => "${repository}/${name}-${version}",
  }

  $pear_exec_command = $ensure ? {
    'present' => "pear -d preferred_state=${preferred_state} install ${manage_alldeps} ${pear_source}",
    'absent'  => "pear uninstall -n ${pear_source}",
  }

  $pear_exec_require = $repository ? {
    'pear.php.net' => Package['php-pear'],
    default        => [Package['php-pear'],Php::Pear::Config['auto_discover']],
  }

  $pear_exec_unless = $ensure ? {
    'present' => "pear shell-test ${pear_source} > 0",
    'absent'  => undef
  }

  $pear_exec_onlyif = $ensure ? {
    'present' => undef,
    'absent'  => "pear shell-test ${pear_source} > 0",
  }

  $service_ref = $service ? {
    ''      => undef,
    default => Service[$service],
  }

  $real_service_autorestart = $service_autorestart ? {
    true    => $service_ref,
    false   => undef,
  }

  $real_module_prefix = $module_prefix ? {
    ''      => $psick::php::pear_module_prefix,
    default => $module_prefix,
  }
  $package_name = "${real_module_prefix}${name}"

  $real_install_options = $install_options ? {
    ''      => $psick::php::install_options,
    default => $install_options,
  }

  case $bool_use_package {
    true: {
      package { "pear-${name}":
        ensure          => $ensure,
        name            => $package_name,
        install_options => $real_install_options,
        notify          => $real_service_autorestart,
      }
    }
    default: {
      if $repository != 'pear.php.net' {
        if !defined (Php::Pear::Config['auto_discover']) {
          psick::php::pear::config { 'auto_discover':
            value => '1',
          }
        }
      }
      exec { "pear-${name}":
        command => $pear_exec_command,
        path    => $path,
        unless  => $pear_exec_unless,
        onlyif  => $pear_exec_onlyif,
        require => $pear_exec_require,
        timeout => $timeout,
      }
    }
  } # End Case
}
