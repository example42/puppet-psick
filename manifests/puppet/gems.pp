# This class installs the gems needed to run Puppet with this control-repo
#
class psick::puppet::gems (
  Enum['present','absent'] $ensure     = 'present',
  Enum['none','client','master','developer','citest','cideploy','integration'] $default_set = 'client',
  Array $install_gems                  = [ ],
  Array $install_options               = [ ],
  Boolean $install_system_gems         = false,
  Boolean $install_puppet_gems         = true,
  Boolean $install_puppetserver_gems   = false,
  Boolean $install_rbenv_gems          = false,
  Optional[String] $rbenv_ruby_version = undef,       
  Boolean $no_noop                     = false,
  Boolean $auto_prereq                 = $::psick::auto_prereq,
) {

  if $no_noop {
    info('Forced no-noop mode.')
    noop(false)
  }

  $minimal_gems = ['r10k','hiera-eyaml','deep_merge']
  $minimal_test_gems = ['puppet-lint','rspec-puppet','rake','bundler','simplecov','minitest','rspec-puppet-facts','puppetlabs_spec_helper']

  $default_gems = $default_set ? {
    'none'      => [],
    'client'    => [],
    'master'    => $minimal_gems,
    'cideploy'  => $minimal_gems + $minimal_test_gems,
    'citest'    => $minimal_gems + $minimal_test_gems,
    'integration' => $minimal_gems + $minimal_test_gems + ['beaker','beaker-rspec','beaker-puppet_install_helper'],
    'developer' => $minimal_gems + $minimal_test_gems + ['puppet-debug','puppet-blacksmith'],
  }

  if $install_rbenv_gems and $auto_prereq {
    include psick::rbenv
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
    if $install_rbenv_gems and $gem != 'bundler' {
      # bundler gem already installed by rbenv module
      $rbenv_require = $auto_prereq ? {
        true  => Class['psick::rbenv'],
        false => undef,
      }
      rbenv::gem { $gem:
        ruby_version => pick($rbenv_ruby_version,$::psick::rbenv::default_ruby_version),
        skip_docs    => true,
        require      => $rbenv_require,
      }
    }
  }
}
