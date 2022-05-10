# psick::docker::install
#
# @summary This tp profile manages docker with Tiny Puppet (tp)
#
# When you include this class the relevant tp::install define is declared
# which is expected to install docker package and manage its service.
# Via the resources_hash parameter is possible to pass hashes of tp::conf and
# tp::dir defines which can manage docker configuration files and
# whole dirs.
# All the parameters ending with the _hash suffix expect and Hash and are looked
# up on Hiera via the deep merge lookup option.
#
# @example Just include it to install docker
#   include psick::docker::install
#
# @example Include via psick module classification (yaml)
#   psick::profiles::linux_classes:
#     docker: psick::docker::install
#
# @example To use upstream repos instead of OS defaults (if tinydata available) as packages source:
#   psick::docker::install::upstream_repo: true
#
# @example Manage extra configs via hiera (yaml) with templates based on custom options
#   psick::docker::install::ensure: present
#   psick::docker::install::resources:
#     tp::conf:
#       docker:
#         epp: profile/docker/docker.conf.epp
#       docker::dot.conf:
#         epp: profile/docker/dot.conf.epp
#         base_dir: conf
#     exec:
#       docker::setup:
#         command: '/usr/local/bin/docker_setup'
#         creates: '/opt/docker'
#   psick::docker::install::options:
#     key: value
#
# @example Enable default auto configuration, if configurations are available
#   for the underlying system and the given auto_conf value, they are
#   automatically added.
#   psick::docker::install::auto_conf: true
#
# @param manage If to actually manage any resource in this profile or not.
# @param ensure If to install or remove docker. Valid values are present, absent, latest
#   or any version string, matching the expected docker package version.
# @param upstream_repo If to use docker upstream repos as source for packages
#   or rely on default packages from the underlying OS.
#
# @param install_hash An hash of valid params to pass to tp::install defines. Useful to
#   manage specific params that are not automatically defined.
# @param options An open hash of options to use in the templates referenced
#   in the tp::conf entries of the $resources_hash.
# @param settings_hash An hash of tp settings to override default docker file
#   paths, package names, repo info and whatever tinydata that matches Tp::Settings data type:
#   https://github.com/example42/puppet-tp/blob/master/types/settings.pp.
#
# @param auto_conf If to enable automatic configuration of docker based on the
#   resources_auto_conf_hash and options_auto_conf_hash parameters, if present in
#   data/common/docker.yaml. You can both override them in your Hiera files
#   and merge them with your resources and options.
# @param resources_auto_conf_hash The default resources hash if auto_conf is true.
#   The final resources managed are the ones specified here and in $resources.
#   Check psick::docker::install::resources_auto_conf_hash in
#   data/common/docker.yaml for the auto_conf defaults.
# @param options_auto_conf_hash The default options hash if auto_conf is set.
#   Check psick::docker::install::options_auto_conf_hash in
#   data/common/docker.yaml for the auto_conf defaults.
#
# @param resources An hash of any resource, like tp::conf, tp::dir, exec or whatever
#   to declare for docker confiuration. Can also come from a third-party
#   component modules with dedicated docker resources.
#   tp::conf params: https://github.com/example42/puppet-tp/blob/master/manifests/conf.pp
#   tp::dir params: https://github.com/example42/puppet-tp/blob/master/manifests/dir.pp
#   any other Puppet resource type, with relevant params can be actually used
#   The Hiera lookup method used for this parameter is defined with the $resource_lookup_method
#   parameter.
# @param resource_lookup_method What lookup method to use for psick::docker::install::resources
# @param resources_defaults An Hash of resources with their default params, to be merged with
#   $resources.
#
# @param auto_prereq If to automatically install eventual dependencies for docker.
#   Set to false if you have problems with duplicated resources, being sure that you
#   manage the prerequistes to install docker (other packages, repos or tp installs).
#
# @param noop_manage If to manage noop mode via the noop() function for the resources of
#   this class. This must be true for noop_value to have effect.
# @param noop_value. The parameter passed to the noop() function (from trlinkin-noop module)
#   When true, noop in enforced on all the class' resources.
#   When false, no-noop in enforced on all the class' resources and overrides any other noop
#   setting (also from clients' puppet.conf
#
class psick::docker::install (
  Psick::Ensure $ensure                   = 'present',
  Boolean            $manage                   = true,
  Optional[Boolean]  $upstream_repo            = undef,

  Hash               $install_hash             = {},
  Hash               $settings_hash            = {},

# This param is looked up in code according to $resources_lookup_method
#  Hash               $resources                = {},
  Hash               $resources_defaults       = {},
  Enum['first','deep','hash'] $resources_lookup_method = 'deep',

# This param is looked up in code according to $options_lookup_method
#  Hash               $options                 = {},
  Enum['first','deep','hash'] $options_lookup_method = 'deep',

  Boolean            $auto_conf                = false,
  Hash               $resources_auto_conf_hash = {},
  Hash               $options_auto_conf_hash   = {},

  Boolean            $auto_prereq              = true,

  Boolean            $noop_manage              = false,
  Boolean            $noop_value               = false,
) {

  $options=lookup('psick::docker::install::options', Hash, $options_lookup_method, {})

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    $options_all = $auto_conf ? {
      true  => $options_auto_conf_hash + $options,
      false => $options,
    }

    $install_defaults = {
      ensure        => $ensure,
      options_hash  => $options_all,
      settings_hash => $settings_hash,
      auto_repo     => $auto_prereq,
      auto_prereq   => $auto_prereq,
      upstream_repo => $upstream_repo,
    }
    tp::install { 'docker':
      * => $install_defaults + $install_hash,
    }

    $file_ensure = $ensure ? {
      'absent' => 'absent',
      default  => 'present',
    }
    $dir_ensure = $ensure ? {
      'absent' => 'absent',
      default  => 'directory',
    }

    # Declaration of psick::docker::install::resources
    $resources=lookup('psick::docker::install::resources', Hash, $resources_lookup_method, {})
    $resources.each |String $resource_type, Hash $content| {
      $resources_all = $auto_conf ? {
        true  => pick($resources_auto_conf_hash[$resource_type], {}) + pick($resources[$resource_type], {}),
        false => pick($resources[$resource_type], {}),
      }
      $resources_all.each |String $resource_name, Hash $resource_params| {
        $resources_params_default = $resource_type ? {
          'tp::conf' => {
            ensure        => $file_ensure,
            options_hash  => $options_all,
            settings_hash => $settings_hash,
          },
          'tp::dir' => {
            ensure        => $dir_ensure,
            settings_hash => $settings_hash,
          },
          'exec' => {
            path => $::path,
          },
          'file' => {
            ensure        => $file_ensure,
          },
          'package' => {
            ensure        => $file_ensure,
          },
          default => {},
        }
        $resource_params_all = deep_merge($resources_defaults[$resource_type], $resources_params_default, $resource_params)
        ensure_resource($resource_type,$resource_name,$resource_params_all)
      }
    }
  }
}
