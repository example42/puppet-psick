# This class installs and configures Aws SDK gems
#
# @param ensure Define if to install (present), remote (absent) sdk gems
# @param install_gems The gems to install
# @param install_system_gems If to install danger gems on the system
# @param install_puppet_gems If to install danger gems via puppet gem
#
class psick::aws::sdk (
  String  $ensure              = 'present',
  Array   $install_gems        = [ 'aws-sdk-core' , 'aws-sdk' , 'retries' ],
  Boolean $install_system_gems = true,
  Boolean $install_puppet_gems = true,

  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,

) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $install_gems.each | $gem | {
      if $facts['os']['family'] != 'windows' {
        if $install_system_gems {
          contain ::psick::ruby
          package { $gem:
            ensure   => $ensure,
            provider => 'gem',
            require  => Class['psick::ruby'],
          }
        }
      }
      if $install_puppet_gems {
        package { "puppet_${gem}":
          ensure   => $ensure,
          name     => $gem,
          provider => 'puppet_gem',
        }
      }
    }
  }
}
