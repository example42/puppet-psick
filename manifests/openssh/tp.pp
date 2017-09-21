# psick::openssh::tp
#
# @summary This psick profile manages openssh with Tiny Puppet (tp)
#
# @example Include it to install openssh
#   include psick::openssh::tp
# 
# @example Include in PSICK via hiera (yaml)
#   psick::profiles:
#     openssh: psick::openssh::tp
# 
# @example Manage extra configs via hiera (yaml)
#   psick::openssh::tp::ensure: present
#   psick::openssh::tp::resources_hash:
#     tp::conf:
#       openssh.conf:
#         epp: profile/openssh/openssh.conf.epp
#       dot.conf:
#         epp: profile/openssh/dot.conf.epp
#         base_dir: conf
#
# @example Enable default auto configuration, if configurations are available
#   for the underlying system and the given auto_conf value, they are
#   automatically added (Default value is inherited from global $::psick::auto_conf
#   psick::openssh::tp::auto_conf: 'default'
#
# @param manage If to actually manage any resource or not
# @param ensure If to install or remove openssh
# @param resources_hash An hash of tp conf and dir resources for openssh.
#   tp::conf params: https://github.com/example42/puppet-tp/blob/master/manifests/conf.pp
#   tp::dir params: https://github.com/example42/puppet-tp/blob/master/manifests/dir.pp
# @param options_hash An open hash of options to use in the templates referenced
#   in the $conf_hash. This is passed as parameter to all the tp::conf defines.
#   Note, if an options_hash is set also in the $conf_hash that gets precedence.
#   It's looked up via a deep merge hash
# @param settings_hash An hash of tp settings to customise openssh file
#   paths, package names, repo info and whatever can match Tp::Settings data type:
#   https://github.com/example42/puppet-tp/blob/master/types/settings.pp
# @param auto_prereq If to automatically install eventual dependencies for openssh.
#   Set to false if you have problems with duplicated resources, being sure that you 
#   manage the prerequistes to install openssh (other packages, repos or tp installs).
# @param auto_conf If to automatically use default configurations for openssh.
class psick::openssh::tp (
  Boolean         $manage         = $::psick::manage,
  Psick::Ensure   $ensure         = 'present',
  Hash            $resources_hash = {},
  Hash            $options_hash   = {},
  Hash            $settings_hash  = {},
  Boolean         $auto_prereq    = $::psick::auto_prereq,
  Psick::Autoconf $auto_conf      = $::psick::auto_conf,
) {

  if $manage {
    # tp::install openssh
    $install_defaults = {
      ensure             => $ensure,
      options_hash       => $options_hash,
      settings_hash      => $settings_hash,
      auto_repo          => $auto_prereq,
      auto_prerequisites => $auto_prereq,
    }
    ::tp::install { 'openssh':
      * => $install_defaults,
    }
  
    # tp::conf iteration based on 
    $file_ensure = $ensure ? {
      'absent' => 'absent',
      default  => 'present',
    }
    $all_options_hash = lookup("openssh::options_hash_${auto_conf}", Hash, 'deep', {}) + $options_hash 
    $conf_defaults = {
      ensure             => $file_ensure,
      options_hash       => $all_options_hash,
      settings_hash      => $settings_hash,
    }
    $resources_auto_conf = lookup("openssh::resources_hash_${auto_conf}", Hash, 'deep', {})
    $tp_confs = pick($resources_auto_conf['tp::conf'], {}) + pick($resources_hash['tp::conf'], {}) 
    # All the tp::conf defines declared here
    $tp_confs.each | $k,$v | {
      ::tp::conf { $k:
        * => $conf_defaults + $v,
      }
    }
  
    # tp::dir iterated over $dir_hash
    $dir_ensure = $ensure ? {
      'absent' => 'absent',
      default  => 'directory',
    }
    $dir_defaults = {
      ensure             => $dir_ensure,
      settings_hash      => $settings_hash,
    }
    # All the tp::dir defines declared here
    $tp_dirs = pick($resources_auto_dir['tp::dir'], {}) + pick($resources_hash['tp::dir'], {}) 
    $tp_dirs.each | $k,$v | {
      ::tp::dir { $k:
        * => $dir_defaults + $v,
      }
    }
  }
}

