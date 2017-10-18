# This class installs and configures bolt via rubygems.
#
# @param ensure Define if to install (present), remote (absent) bolt gem
#
class psick::bolt::gem (
  String $ensure               = 'present',
  Boolean $install_system_gems = false,
  Boolean $install_puppet_gems = true,
) {

  if $install_system_gems {
    include ::psick::ruby
    include ::psick::ruby::buildgems
    package { 'bolt':
      ensure   => $ensure,
      provider => 'gem',
      require  => [ Class['psick::ruby'],Class['psick::ruby::buildgems'] ],
    }
  }

  if $install_puppet_gems {
    package { 'bolt':
      ensure   => $ensure,
      provider => 'puppet_gem',
    }
  }

}
