# @class rbenv
#
class psick::rbenv (

  Variant[Boolean,String] $ensure = present,
  Enum['jdowning']        $module = 'jdowning',

  Optional[String] $default_ruby_version = '2.4.2',
  Optional[String] $install_dir = undef,
  Optional[String] $owner       = undef,
  Optional[String] $group       = undef,
  Optional[String] $latest      = undef,

  Hash               $plugin_hash = {},
  Hash               $build_hash  = {},
  Hash               $gem_hash    = {},

  Boolean $auto_prereq                    = $::psick::auto_prereq,

) {

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
