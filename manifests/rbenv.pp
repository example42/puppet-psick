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
# @param auto_prereq If to automatically install eventual dependencies required
#   by this class. Set to false if you have problems with duplicated resources.
#   If so, you'll need to ensure the needed prerequisites are present.
# @param manage If to actually manage any resource in this class. If false no
#               resource is managed. Default value is taken from main psick class.
# @param noop_manage If to use the noop() function for all the resources provided
#                    by this class. If this is true the noop function is called
#                    with $noop_value argument. This overrides any other noop setting
#                    (either set on client's puppet.conf or by noop() function in
#                    main psick class). Default from psick class.
# @param noop_value The value to pass to noop() function if noop_manage is true.
#                   It applies to all the resources (and classes) declared in this class
#                   If true: noop metaparamenter is set to true, resources are not applied
#                   If false: noop metaparameter is set to false, and any eventual noop
#                   setting is overridden: resources are always applied.
#                   Default from psick class.
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
  Boolean $noop_manage                   = $::psick::noop_manage,
  Boolean $noop_value                    = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
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
