# @class Manages rbenv using jdowning/rbenv module
#
# @param module The name of the module to use to manage rbenv. Currently
#   only jdowning/rbenv supported.
# @param default_ruby_version Default ruby version to use under rbenv. When set
#   (default is '2.4.2') the relevant rbenv::build is created
# @param Where rbenv will be installed to.
# @param owner This defines who owns the rbenv install directory.
# @param group This defines the group membership for rbenv.
# @param latest This defines whether the rbenv $install_dir is kept up-to-date.
# @param plugin_hash An hash of resources data to be passed to rbenv::plugin
# @param build_hash An hash of resources data to be passed to rbenv::build
# @param gem_hash An hash of resources data to be passed to rbenv::gem
# @param manage If to actually manage ANY resource from this class.
#   When set to false, no resource from this class is managed whatever are
#   the other parameters.
# @param auto_prereq If to automatically install eventual dependencies required
#   by this class. Set to false if you have problems with duplicated resources.
#   If so, you'll need to ensure the needed prerequisites are present.
# @param no_noop Set noop metaparameter to false to all the resources of this class.
#   This overrides any noop setting which might be in place.
#
class psick::rbenv (

  Variant[Boolean,String] $ensure        = present,
  Enum['jdowning'] $module               = 'jdowning',

  Optional[String] $default_ruby_version = '2.4.2',
  Optional[String] $install_dir          = undef,
  Optional[String] $owner                = undef,
  Optional[String] $group                = undef,
  Optional[String] $latest               = undef,

  Hash $plugin_hash                      = {},
  Hash $build_hash                       = {},
  Hash $gem_hash                         = {},

  Boolean $manage                        = $::psick::manage,
  Boolean $auto_prereq                   = $::psick::auto_prereq,
  Boolean $no_noop                       = false,
) {

  if $manage {
    if !$::psick::noop_mode and $no_noop {
      info('Forced no-noop mode.')
      noop(false)
    }

    # Installation management
    case $module {
      'jdowning': {
        class { 'rbenv':
          manage_deps => $auto_prereq,
          install_dir => $install_dir,
          owner       => $owner,
          group       => $group,
          latest      => $latest,
        }
        $default_gem_options = {
          ruby_version => $default_ruby_version,
        }
        if $default_ruby_version and $auto_prereq {
          rbenv::plugin { 'rbenv/ruby-build': }
          rbenv::build { $default_ruby_version:
            global => true,
          }
        }
        $plugin_hash.each |$k,$v| {
          rbenv::plugin { $k:
            * => $v,
          }
        }
        $build_hash.each |$k,$v| {
          rbenv::build { $k:
            * => $v,
          }
        }
        $gem_hash.each |$k,$v| {
          rbenv::gem { $k:
            * => $default_gem_options + $v,
          }
        }
      }
      default: {
        contain ::rbenv
      }
    }
  }
}
