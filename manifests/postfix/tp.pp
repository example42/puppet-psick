# psick::postfix::tp
#
# @summary This psick profile manages postfix with Tiny Puppet (tp)
#
# @example Include it to install postfix
#   include psick::postfix::tp
# 
# @example Include in PSICK via hiera (yaml)
#   psick::profiles:
#     postfix: psick::postfix::tp
# 
# @example Manage extra configs via hiera (yaml)
#   psick::postfix::tp::ensure: present
#   psick::postfix::tp::conf_hash:
#     postfix.conf:
#       epp: profile/postfix/postfix.conf.epp
#     dot.conf:
#       epp: profile/postfix/dot.conf.epp
#       base_dir: conf
#
# @param manage If to actually manage any resource or not
# @param ensure If to install or remove postfix
# @param tp_hash An hash of tp conf and dir resources for postfix.
#   tp::conf params: https://github.com/example42/puppet-tp/blob/master/manifests/conf.pp
#   tp::dir params: https://github.com/example42/puppet-tp/blob/master/manifests/dir.pp
# @param options_hash An open hash of options to use in the templates referenced
#   in the $conf_hash. This is passed as parameter to all the tp::conf defines.
#   Note, if an options_hash is set also in the $conf_hash that gets precedence.
#   It's looked up via a deep merge hash
# @param settings_hash An hash of tp settings to customise postfix file
#   paths, package names, repo info and whatever can match Tp::Settings data type:
#   https://github.com/example42/puppet-tp/blob/master/types/settings.pp
# @param auto_prereq If to automatically install eventual dependencies for postfix.
#   Set to false if you have problems with duplicated resources, being sure that you 
#   manage the prerequistes to install postfix (other packages, repos or tp installs).
# @param auto_conf If to automatically use default configurations for postfix.
# @param auto_conf_defaults If auto_conf is this, this Hash contains the tp resources to
#   apply. This can be different according to the underlying OS.
class psick::postfix::tp (
  Boolean       $manage         = $::psick::manage,
  Psick::Ensure $ensure         = 'present',
  Hash          $tp_hash        = {},
  Hash          $options_hash   = {},
  Hash          $settings_hash  = {},
  Boolean       $auto_prereq    = $::psick::auto_prereq,
  Boolean       $auto_conf      = $::psick::auto_conf,
  Hash          $auto_conf_hash = {},
) {

  if $manage {
    # tp::install postfix
    $install_defaults = {
      ensure             => $ensure,
      options_hash       => $options_hash,
      settings_hash      => $settings_hash,
      auto_repo          => $auto_prereq,
      auto_conf          => $auto_conf,
      auto_prerequisites => $auto_prereq,
    }
    ::tp::install { 'postfix':
      * => $install_defaults,
    }
  
    # tp::conf
    $conf_defaults = {
      ensure             => $ensure,
      options_hash       => $options_hash,
      settings_hash      => $settings_hash,
    }
    $tp_confs = $auto_conf ? {
      true  => pick($auto_conf_hash['tp::conf'], {}) + pick($tp_hash['tp::conf'], {}),
      false => pick($tp_hash['tp::conf'], {}),
    }
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
    $tp_dirs = $auto_conf ? {
      true  => pick($auto_conf_hash['tp::dir'], {}) + pick($tp_hash['tp::dir'], {}),
      false => pick($tp_hash['tp::dir'], {}),
    }
    # All the tp::dir defines declared here
    $tp_dirs.each | $k,$v | {
      ::tp::dir { $k:
        * => $dir_defaults + $v,
      }
    }
  }
}

