# psick::puppetserver::tp
#
# @summary This psick profile manages puppetserver with Tiny Puppet (tp)
#
# @example Include it to install puppetserver
#   include psick::puppetserver::tp
#
# @example Include in PSICK via hiera (yaml)
#   psick::profiles::linux_classes:
#     puppetserver: psick::puppetserver::tp
#
# @example Manage extra configs via hiera (yaml) with templates based on custom options
#   psick::puppetserver::tp::ensure: present
#   psick::puppetserver::tp::resources_hash:
#     tp::conf:
#       puppetserver:
#         epp: profile/puppetserver/puppetserver.conf.epp
#       puppetserver::dot.conf:
#         epp: profile/puppetserver/dot.conf.epp
#         base_dir: conf
#   psick::puppetserver::tp::options_hash:
#     key: value
#
# @example Enable default auto configuration, if configurations are available
#   for the underlying system and the given auto_conf value, they are
#   automatically added (Default value is inherited from global $::psick::auto_conf
#   psick::puppetserver::tp::auto_conf: 'default'
#
# @param manage If to actually manage any resource in this profile or not
# @param ensure If to install or remove puppetserver. Valid values are present, absent, latest
#   or any version string, matching the expected puppetserver package version.
# @param resources_hash An hash of tp::conf and tp::dir resources for puppetserver.
#   tp::conf params: https://github.com/example42/puppet-tp/blob/master/manifests/conf.pp
#   tp::dir params: https://github.com/example42/puppet-tp/blob/master/manifests/dir.pp
# @param resources_auto_conf_hash The default resources hash if auto_conf is set. Default
#   value is based on $::psick::auto_conf. Can be overridden or set to an empty hash.
#   The final resources manages are the ones specified here and in $resources_hash.
#   Check psick::puppetserver::tp:resources_auto_conf_hash in data/$auto_conf/*.yaml for
#   the auto_conf defaults.
# @param options_hash An open hash of options to use in the templates referenced
#   in the tp::conf entries of the $resouces_hash.
# @param options_auto_conf_hash The default options hash if auto_conf is set.
#   Check psick::puppetserver::tp:options_auto_conf_hash in data/$auto_conf/*.yaml for
#   the auto_conf defaults.
# @param settings_hash An hash of tp settings to override default puppetserver file
#   paths, package names, repo info and whatever can match Tp::Settings data type:
#   https://github.com/example42/puppet-tp/blob/master/types/settings.pp
# @param auto_prereq If to automatically install eventual dependencies for puppetserver.
#   Set to false if you have problems with duplicated resources, being sure that you
#   manage the prerequistes to install puppetserver (other packages, repos or tp installs).
# @param no_noop Set noop metaparameter to false to all the resources of this class.
#   This overrides client site noop setting but not $psick::noop_mode.
class psick::puppetserver::tp (
  Psick::Ensure   $ensure                   = 'present',
  Boolean         $manage                   = $::psick::manage,
  Hash            $resources_hash           = {},
  Hash            $resources_auto_conf_hash = {},
  Hash            $options_hash             = {},
  Hash            $options_auto_conf_hash   = {},
  Hash            $settings_hash            = {},
  Boolean         $auto_prereq              = $::psick::auto_prereq,
  Boolean         $no_noop                  = false,
) {

  if $manage {
    if !$::psick::noop_mode and $no_noop {
      info('Forced no-noop mode in psick::puppetserver::tp')
      noop(false)
    }
    $options_all = $options_auto_conf_hash + $options_hash
    $install_defaults = {
      ensure        => $ensure,
      options_hash  => $options_all,
      settings_hash => $settings_hash,
      auto_repo     => $auto_prereq,
      auto_prereq   => $auto_prereq,
    }
    tp::install { 'puppetserver':
      * => $install_defaults,
    }

    # tp::conf iteration based on
    $file_ensure = $ensure ? {
      'absent' => 'absent',
      default  => 'present',
    }
    $conf_defaults = {
      ensure        => $file_ensure,
      options_hash  => $options_all,
      settings_hash => $settings_hash,
    }
    $tp_confs = pick($resources_auto_conf_hash['tp::conf'], {}) + pick($resources_hash['tp::conf'], {})
    # All the tp::conf defines declared here
    $tp_confs.each | $k,$v | {
      tp::conf { $k:
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
      tp::dir { $k:
        * => $dir_defaults + $v,
      }
    }
  }
}
