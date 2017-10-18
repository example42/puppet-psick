# This class installs the gems needed to run Puppet with this control-repo
#
class psick::puppet::gems (
  Enum['present','absent'] $ensure   = 'present',
  Array $install_gems = [ 'r10k','deep_merge','hiera-eyaml' ],
  Array $install_options             = [ ],
  Boolean $install_system_gems       = true,
  Boolean $install_puppet_gems       = true,
  Boolean $install_puppetserver_gems = false,
) {

  $install_gems.each | $gem | {
    if $install_system_gems {
      include ::psick::ruby
      package { $gem:
        ensure          => $ensure,
        install_options => $install_options,
        provider        => 'gem',
        require         => Class['psick::ruby'],
      }
    }
    if $install_puppet_gems {
      if !defined(Class['r10k']) {
        package { "puppet_${gem}":
          ensure          => $ensure,
          name            => $gem,
          install_options => $install_options,
          provider        => 'puppet_gem',
        }
      }
    }
    if $install_puppetserver_gems {
      package { "puppetserver_${gem}":
        ensure          => $ensure,
        name            => $gem,
        install_options => $install_options,
        provider        => 'puppetserver_gem',
      }
    }
  }
}
