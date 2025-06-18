# @summary This class manages nodejs either via system packages or via NVM
#
# The class allows full management of nodejs
#
# @param ensure If to install or remove the resources managed by this
#   class. Can be present, absent, latest or a specific package version number
#
# @param package_manage If to install the global nodejs rpm package.
#
# @param package_name The name of the package to install
#
# @param package_params An hash of additional params to pass as arguments to the
#   package resource. Use this for special needs.
#
# @param setup_script_manage If to manage the download and execution of setup script
#                            for yum repo
#
# @param setup_script_url The url from where to download the setup script
#
# @param setup_script_path The path where to download the setup script.
#
# @param setup_script_creates A file created by the setup script (the yum repo)
#
# @param nvm_manage If to manage the installation of jodejs via NVM (which is automatically
#                   installable for different users)
#
# @params nvm_installs An hash of custom psick::nvm resources. Title is the user for which
#                      to install nvm.
#
# @example Install a specific version of the package
#   psick::nodejs::ensure: '0.4.2'
#   psick::nodejs::package_manage: true
#
# @example Remove all the resources managed by the class
#   psick::nodejs::ensure: 'absent'
#
# @example Install nodejs via nvm for a given user. It's defined the default nodejs version
#          and optionally a list on npm packages
# psick::nodejs::nvm_manage: true
# psick::nodejs::nvm_installs:
#   mastermonkey:
#     node_instance_default: '8.12.0'
#     npm_packages:
#       yarn: {}
#       pm2:
#         version: 2.10.4
class psick::nodejs (

  String $ensure          = 'present',

  Boolean $package_manage = false,
  String $package_name    = 'nodejs',
  Hash $package_params    = {},

  Boolean $setup_script_manage = false,
  String $setup_script_url     = 'https://rpm.nodesource.com/setup_10.x',
  String $setup_script_path    = '/tmp/NodeJS',
  Hash $setup_script_params    = {},
  String $setup_script_creates = '', # lint:ignore:params_empty_string_assignment

  Boolean $nvm_manage          = false,
  Hash $nvm_installs           = {},
) {
  # Setup script management
  if $setup_script_manage {
    archive { $setup_script_path:
      ensure        => $ensure,
      source        => $setup_script_url,
      extract       => false,
      checksum_type => 'none',
      cleanup       => false,
      before        => Package[$package_name],
      notify        => Exec['nodejs setup'],
    }
    $setup_script_default_params = {
      command => "/bin/bash ${setup_script_path} > njs_setup.txt",
      creates => $setup_script_creates,
    }
    exec { 'nodejs setup':
      * => $setup_script_default_params + $setup_script_params,
    }
  }

  # Package management
  if $package_manage {
    $package_defaults = {
      ensure => $ensure,
    }
    package { $package_name:
      * => $package_defaults + $package_params,
    }
  }

  $nvm_installs.each | $k,$v | {
    psick::nodejs::nvm { $k:
      * => $v,
    }
  }
}
