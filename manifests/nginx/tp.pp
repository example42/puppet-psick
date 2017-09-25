# psick::nginx::tp
#
# @summary This psick profile manages nginx with Tiny Puppet (tp)
#
# @example Include it to install nginx
#   include psick::nginx::tp
# 
# @example Include in PSICK via hiera (yaml)
#   psick::profiles:
#     nginx: psick::nginx::tp
# 
# @example Manage extra configs via hiera (yaml)
#   psick::nginx::tp::ensure: present
#   psick::nginx::tp::resources_hash:
#     tp::conf:
#       nginx.conf:
#         epp: profile/nginx/nginx.conf.epp
#       dot.conf:
#         epp: profile/nginx/dot.conf.epp
#         base_dir: conf
#
# @example Enable default auto configuration, if configurations are available
#   for the underlying system and the given auto_conf value, they are
#   automatically added (Default value is inherited from global $::psick::auto_conf
#   psick::nginx::tp::auto_conf: 'default'
#
# @param manage If to actually manage any resource or not
# @param ensure If to install or remove nginx
# @param resources_hash An hash of tp conf and dir resources for nginx.
#   tp::conf params: https://github.com/example42/puppet-tp/blob/master/manifests/conf.pp
#   tp::dir params: https://github.com/example42/puppet-tp/blob/master/manifests/dir.pp
# @param options_hash An open hash of options to use in the templates referenced
#   in the $conf_hash. This is passed as parameter to all the tp::conf defines.
#   Note, if an options_hash is set also in the $conf_hash that gets precedence.
#   It's looked up via a deep merge hash
# @param settings_hash An hash of tp settings to customise nginx file
#   paths, package names, repo info and whatever can match Tp::Settings data type:
#   https://github.com/example42/puppet-tp/blob/master/types/settings.pp
# @param auto_prereq If to automatically install eventual dependencies for nginx.
#   Set to false if you have problems with duplicated resources, being sure that you 
#   manage the prerequistes to install nginx (other packages, repos or tp installs).
# @param auto_conf If to automatically use default configurations for nginx.
class psick::nginx::tp (
  Psick::Ensure   $ensure                   = 'present',
  Boolean         $manage                   = $::psick::manage,
  Hash            $resources_hash           = {},
  Hash            $resources_auto_conf_hash = {},
  Hash            $options_hash             = {},
  Hash            $options_auto_conf_hash   = {},
  Hash            $settings_hash            = {},
  Boolean         $auto_prereq              = $::psick::auto_prereq,
) {

  if $manage {
    # tp::install nginx
    $install_defaults = {
      ensure        => $ensure,
      options_hash  => $options_auto_conf_hash + $options_hash,
      settings_hash => $settings_hash,
      auto_repo     => $auto_prereq,
      auto_prereq   => $auto_prereq,
    }
    ::tp::install { 'nginx':
      * => $install_defaults,
    }

    # tp::conf iteration based on 
    $file_ensure = $ensure ? {
      'absent' => 'absent',
      default  => 'present',
    }
    $conf_defaults = {
      ensure             => $file_ensure,
      options_hash       => $options_auto_conf_hash + $options_hash,
      settings_hash      => $settings_hash,
    }
    $tp_confs = pick($resources_auto_conf_hash['tp::conf'], {}) + pick($resources_hash['tp::conf'], {})
    # All the tp::conf defines declared here
    $tp_confs.each | $k,$v | {
      ::tp::conf { $k:
        * => $conf_defaults + $v,
      }
    }

    # tp::dir iterated over $dir_hash
    $dir_defaults = {
      ensure             => $file_ensure,
      settings_hash      => $settings_hash,
    }
    # All the tp::dir defines declared here
    $tp_dirs = pick($resources_auto_conf_hash['tp::dir'], {}) + pick($resources_hash['tp::dir'], {})
    $tp_dirs.each | $k,$v | {
      ::tp::dir { $k:
        * => $dir_defaults + $v,
      }
    }
  }
}
