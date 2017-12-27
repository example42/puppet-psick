# This class installs the gems needed to run Puppet with this control-repo
#
class psick::puppet::gems (
  Enum['present','absent'] $ensure   = 'present',
  Enum['none','client','master','developer','citest','cideploy'] $default_set = 'client',
  Array $install_gems                = [ ],
  Array $install_options             = [ ],
  Boolean $install_system_gems       = false,
  Boolean $install_puppet_gems       = true,
  Boolean $install_puppetserver_gems = false,

  Boolean $no_noop                   = false,
) {

  if $no_noop {
    info('Forced no-noop mode.')
    noop(false)
  }

  $default_gems = $default_set ? {
    'none'      => [],
    'client'    => [],
    'master'    => ['r10k','hiera-eyaml','deep_merge'],
    'cideploy'  => ['r10k','hiera-eyaml','deep_merge'],
    'citest'    => ['puppet-lint','rspec-puppet'],
    'developer' => ['puppet-debug','puppet-blacksmith'],
  }

  $all_gems = $default_gems + $install_gems
  $all_gems.each | $gem | {
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
