# Manages /etc/puppetlabs/ci.conf file, used by Puppet CI scripts
# under Psick's control-repo bin directory
# This file contains the names of the node where to run specific
# Puppet CI steps.
class psick::puppet::ci (
  String                $ensure           = 'present',
  String                $config_file_path = '/etc/puppetlabs/ci.conf',
  Variant[Undef,String] $template         = 'psick/puppet/ci/ci.conf.erb',
  Hash                  $options          = { },
  Array                 $default_nodes    = [],
  Array                 $always_nodes     = [],
  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    $options_default = {
      default_nodes => $default_nodes,
      always_nodes => $always_nodes,
    }
    $parameters = $options_default + $options
    file { $config_file_path:
      ensure  => $ensure ,
      content => template($template),
    }
  }
}
