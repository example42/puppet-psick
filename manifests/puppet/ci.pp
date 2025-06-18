# Manages /etc/puppetlabs/ci/ files, used by Puppet CI scripts
# under Psick's control-repo bin directory
# This file contains the names of the node where to run specific
# Puppet CI steps.
class psick::puppet::ci (
  String                $ensure           = 'present',
  String                $config_dir_path   = '/etc/puppetlabs/ci',
  Array                 $production_nodes_noop    = [],
  Array                 $production_nodes_no_noop = [],
  Array                 $canary_nodes_noop        = [],
  Array                 $canary_nodes_no_noop     = [],
  Array                 $diff_nodes               = [],
  Boolean $manage                  = $psick::manage,
  Boolean $noop_manage             = $psick::noop_manage,
  Boolean $noop_value              = $psick::noop_value,
  Array $modules                                  = [],
  String $modules_user                            = 'root',
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    file { $config_dir_path:
      ensure => directory,
      mode   => '0755',
    }
    if $production_nodes_noop != [] {
      file { "${config_dir_path}/production_nodes_noop.txt":
        ensure  => $ensure,
        content => join($production_nodes_noop,"\n"),
      }
    }
    if $production_nodes_no_noop != [] {
      file { "${config_dir_path}/production_nodes_no_noop.txt":
        ensure  => $ensure,
        content => join($production_nodes_no_noop,"\n"),
      }
    }
    if $canary_nodes_noop != [] {
      file { "${config_dir_path}/canary_nodes_noop.txt":
        ensure  => $ensure,
        content => join($canary_nodes_noop,"\n"),
      }
    }
    if $canary_nodes_no_noop != [] {
      file { "${config_dir_path}/canary_nodes_no_noop.txt":
        ensure  => $ensure,
        content => join($canary_nodes_no_noop,"\n"),
      }
    }
    if $diff_nodes != [] {
      file { "${config_dir_path}/diff_nodes.txt":
        ensure  => $ensure,
        content => join($diff_nodes,"\n"),
      }
    }
    if $modules != [] {
      $modules.each | $m | {
        psick::puppet::module { $m:
          user => $modules_user,
        }
      }
    }
  }
}
