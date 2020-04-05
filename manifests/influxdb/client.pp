# Class psick::influxdb::client
# 
# @summary This class installs influxdb-client package
#
# @example Install influxdb-client
#   include psick::influxdb::client
#
#  @param ensure The ensure parameter for the package
#  @param package_name the name of the package to install
#  @param package_params An hash of params to set or override the
#    arguments passed to the package resource
#
# NOTE: this won't work until https://github.com/influxdata/influxdb/issues/6657
#       is closed
class psick::influxdb::client (
  Psick::Ensure $ensure = 'present',
  String $package_name  = 'influxdb-client',
  Hash $package_params  = {},
  Boolean $manage       = $::psick::manage,
  Boolean $noop_manage  = $::psick::noop_manage,
  Boolean $noop_value   = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $package_default_options = {
      'ensure' => $ensure,
    }

    package { $package_name:
      * => $package_default_options + $package_params,
    }
  }
}
