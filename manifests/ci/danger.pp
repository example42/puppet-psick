# This class installs and configures danger, used to automatically
# add comments to Merge/Push Requests during CI pipelines
# Danger homepage: http://danger.systems/
#
# @param ensure Define if to install (present), remote (absent) danger gems
# @param use_gitlab If GitLab (and the relevant danger gem) is used
# @param install_system_gems If to install danger gems on the system
# @param install_puppet_gems If to install danger gems via puppet gem
#
class psick::ci::danger (
  String $ensure               = 'present',
  Array $plugins               = [ ],
  Boolean $use_gitlab          = false,
  Boolean $install_system_gems = false,
  Boolean $install_puppet_gems = true,

  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    include ::psick::ruby

    $all_gems = $use_gitlab ? {
      true  => ['danger-gitlab'] + $plugins,
      false => ['danger'] + $plugins,
    }

    $all_gems.each | $gem | {
      if $install_system_gems {
        package { $gem:
          ensure   => $ensure,
          provider => 'gem',
          require  => Class['psick::ruby'],
        }
      }
      if $install_puppet_gems {
        package { "puppet_${gem}":
          ensure   => $ensure,
          name     => $gem,
          provider => 'puppet_gem',
          require  => Class['psick::ruby'],
        }
      }
    }
  }
}
