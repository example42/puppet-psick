# This class installs the gems needed to run Puppet with this control-repo
# It can be also be used to install any gem on any gem environment (Puppet,
# PuppetServer, System, RBenv...).
#
# @example Install under rbenv environment gems needed for CI tests:
#     psick::puppet::gems::default_set: citest
#     psick::puppet::gems::install_puppet_gems: false
#     psick::puppet::gems::install_rbenv_gems: true
#
# @example Install under system, puppet and puppet server environment
#   gems needed for server. Add a specific gem for puppetserver only
#     psick::puppet::gems::default_set: 'master
#     psick::puppet::gems::install_puppet_gems: true
#     psick::puppet::gems::install_puppetserver_gems: true
#     psick::puppet::gems::install_system_gems: true
#     psick::puppet::gems::additional_puppetserver_gems:
#       - hiera-mysql
#
# @param ensure Set status of managed resources
# @param default_set Define a set of default gems to install for different
#   use cases. Possible values: 'none','client','master','developer','citest',
#   'cideploy','integration'. Gems defined here are installed under all the
#   environments set by install_*_gems params. 
# @param install_gems Array of additional custom gems to install under all the
#   environments set by install_*_gems params.
# @param install_options Optional optional to add to the package provider when
#   installing gems
# @param install_system_gems Manage installation of gems using system's gem
# @param install_puppet_gems Manage installation of gems using Puppet's gem
# @param install_puppetserver_gems Manage installation of gems using Puppetserver's gem
# @param install_rbenv_gems Manage installation of gems under rbenv (requires
#   jdowning/rbenv or compatible module)
# @param install_chruby_gems Manage installation of gems under chruby (uses
#   psick::chruby profile
# @param additional_system_gems Array of additional gems to install using system's gem
# @param additional_puppet_gems Array of additional gems to install using Puppet's gem
# @param additional_puppetserver_gems Array of additional gems to install using
#   Puppetserver's gem
# @param additional_rbenv_gems Array of additional gems to install under rbenv
# @param additional_chruby_gems Array of additional gems to install under chruby
# @param rbenv_ruby_version Ruby version to use under rbenv. Default is from
#   $::psick::rbenv::default_ruby_version
# @param chruby_ruby_version Ruby version to use under chruby. Default is from
#   $::psick::chruby::default_ruby_version
# @param auto_prereq If to automatically install eventual dependencies required
#   by this class. Set to false if you have problems with duplicated resources.
#   If so, you'll need to ensure the needed prerequisites are present.
# @param manage If to actually manage any resource in this class. If false no
#               resource is managed.
# @param noop_manage If to use the noop() function for all the resources provided
#                    by this class. If this is true the noop function is called
#                    with $noop_value argument. This overrides any other noop setting
#                    (either set on client's puppet.conf or by noop() function in
#                    main psick class).
# @param noop_value The value to pass to noop() function if noop_manage is true.
#                   It applies to all the resources (and classes) declared in this class
#                   If true: noop metaparamenter is set to true, resources are not applied
#                   If false: noop metaparameter is set to false, and any eventual noop
#                   setting is overridden: resources are always applied.
#
class psick::puppet::gems (
  Enum['present','absent'] $ensure     = 'present',
  Enum['none','client','master','developer','citest','cideploy','integration'] $default_set = 'none',
  Array $install_gems                  = [ ],
  Array $install_options               = [ ],
  Boolean $install_system_gems         = false,
  Boolean $install_puppet_gems         = true,
  Boolean $install_puppetserver_gems   = false,
  Boolean $install_rbenv_gems          = false,
  Boolean $install_chruby_gems         = false,
  Array $additional_system_gems        = [],
  Array $additional_puppet_gems        = [],
  Array $additional_puppetserver_gems  = [],
  Array $additional_rbenv_gems         = [],
  Array $additional_chruby_gems        = [],
  Optional[String] $rbenv_ruby_version  = undef,
  Optional[String] $chruby_ruby_version = undef,
  Boolean $auto_prereq             = $::psick::auto_prereq,
  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $minimal_gems = ['r10k','hiera-eyaml','deep_merge']
    $minimal_test_gems = ['puppet-lint','rspec-puppet','rake','bundler','simplecov','minitest','puppetlabs_spec_helper','yaml-lint'] # lint:ignore:140chars
    $default_gems = $default_set ? {
      'none'      => [],
      'client'    => [],
      'master'    => $minimal_gems,
      'cideploy'  => $minimal_gems + $minimal_test_gems,
      'citest'    => $minimal_gems + $minimal_test_gems,
      'integration' => $minimal_gems + $minimal_test_gems + ['beaker','beaker-rspec','beaker-puppet_install_helper'],
      'developer' => $minimal_gems + $minimal_test_gems + ['puppet-debug','puppet-blacksmith'],
    }
    $all_gems = $default_gems + $install_gems
    if $install_system_gems {
      if $auto_prereq {
        include ::psick::ruby
      }
      $system_gems = $all_gems + $additional_system_gems
      $system_gems.each | $gem | {
        package { $gem:
          ensure          => $ensure,
          install_options => $install_options,
          provider        => 'gem',
          require         => Class['psick::ruby'],
        }
      }
    }
    if $install_puppet_gems {
      if $auto_prereq {
        include ::psick::ruby::buildgems
      }
      $puppet_gems = $all_gems + $additional_puppet_gems
      $puppet_gems.each | $gem | {
        if !defined(Class['r10k']) {
          package { "puppet_${gem}":
            ensure          => $ensure,
            name            => $gem,
            install_options => $install_options,
            provider        => 'puppet_gem',
            require         => Class['psick::ruby::buildgems'],
          }
        }
      }
    }
    if $install_puppetserver_gems {
      $puppetserver_gems = $all_gems + $additional_puppetserver_gems
      $puppetserver_gems.each | $gem | {
        package { "puppetserver_${gem}":
          ensure          => $ensure,
          name            => $gem,
          install_options => $install_options,
          provider        => 'puppetserver_gem',
        }
      }
    }
    if $install_rbenv_gems {
      if $auto_prereq {
        include ::psick::rbenv
      }
      $rbenv_require = $auto_prereq ? {
        true  => Class['psick::rbenv'],
        false => undef,
      }
      $rbenv_gems = $all_gems + $additional_rbenv_gems
      $rbenv_gems.each | $gem | {
        # bundler gem already installed by rbenv module
        if $gem != 'bundler' {
          rbenv::gem { $gem:
            ruby_version => pick($rbenv_ruby_version,$::psick::rbenv::default_ruby_version),
            skip_docs    => true,
            require      => $rbenv_require,
          }
        }
      }
    }
    if $install_chruby_gems {
      if $auto_prereq {
        include ::psick::chruby
      }
      $chruby_require = $auto_prereq ? {
        true  => Class['psick::chruby'],
        false => undef,
      }
      $chruby_gems = $all_gems + $additional_chruby_gems
      $chruby_gems.each | $gem | {
        psick::chruby::gem { $gem:
          ruby_version => pick($chruby_ruby_version,$::psick::chruby::default_ruby_version),
          require      => $chruby_require,
        }
      }
    }
  }
}
