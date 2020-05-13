# Generic class to manage limits
#
# @description This class can manage system limits in different ways:
#   - Managing the /etc/security/limits.conf with the limits_conf_template, 
#     parameters and limits_conf_source parameters
#   - Managing the /etc/security/limits.d/ directory contents with th
#     limits_dir_source and limits_dir_params parameters
#   - Managing single limits files in /etc/security/limits.d/ with the
#     parameter limits_hash which creates psick::limits::limit resources
#   - Managing single limits files in /etc/security/limits.d/ with the
#     parameter configs_hash which creates psick::limits::config resources
#
# @param limits_conf_template The epp or erb template to use for the main limits file.
# @param limits_conf_source The source to use for the main limits file.
#                           Alternative to limits_conf_template
# @param limits_conf_path The path of the main limits file.
# @param limits_conf_params An hash of params to use for the limits.conf file.
#                           Use this, for example, to override default mode,
#                           onwer or group
# @param parameters Optional custom hash of key values to use in limits_conf_template.
# @param limits_dir_path The path of the limits.d directory.
# @param limits_dir_source The source (as used in source  => ) to use to populate
#                          the limits.d directory
# @param limits_dir_params An hash of params to use for the limits.d diretcory
#                          file resource. Set { recurse  => true, purge => true }
#                          to recursively purge the content of the directory and
#                          use only the files present in limits_dir_source
# @param limits_hash An hash of limits directives to pass to psick::limits::limit
#                    define. Hiera lookup uses deepo merge method.
# @param config_hash An hash of limits files to pass to psick::limits::config
#                    define. Hiera lookup uses deepo merge method.
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
# @example
#   include psick::limits
class psick::limits (
  Optional[String] $limits_conf_template = undef,
  Optional[String] $limits_conf_source   = undef,
  String           $limits_conf_path     = '/etc/security/limits.conf',
  Hash             $limits_conf_params   = {},
  Hash             $parameters           = {},

  String           $limits_dir_path      = '/etc/security/limits.d',
  Optional[String] $limits_dir_source    = undef,
  Hash             $limits_dir_params    = {},

  Hash             $limits_hash          = {},
  Hash             $configs_hash         = {},

  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $limits_conf_source or $limits_conf_template {
      $limits_conf_content = $limits_conf_template ? {
        undef   => undef,
        default => psick::template($limits_conf_template , $parameters),
      }
      $limits_conf_params_default = {
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => $limits_conf_source,
        path    => $limits_conf_path,
        content => $limits_conf_content,
      }
      file { $limits_conf_path:
        * => $limits_conf_params_default + $limits_conf_params,
      }
    }

    $limits_dir_params_default = {
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      recurse => true,
      path    => $limits_dir_path,
      source  => $limits_dir_source,
    }
    file { $limits_dir_path:
      * => $limits_dir_params_default + $limits_dir_params,
    }

    $limits_hash.each |$k,$v| {
      ::psick::limits::limit { $k:
        * => $v,
      }
    }
    $configs_hash.each |$k,$v| {
      ::psick::limits::config { $k:
        * => $v,
      }
    }
  }
}
