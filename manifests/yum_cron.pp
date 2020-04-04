# This class installs and configures yum-cron
#
# @param ensure Define if to install or remove yum-cron
# @param config_file_template The path of the erb template (as used in template)
#                             used for the content of yum-cron config file.
# @param options An hash of custon options to use in the config_file_template
#                Note: This is not a class parameter but a key lookup up via:
#                lookup('psick::yum_cron::options', {} ) and merged with
#                a default hash of options
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
class psick::yum_cron (
  Enum['present','absent'] $ensure = 'present',
  String $config_file_template     = 'psick/yum_cron/yum-cron.conf.erb',

  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    $options_default = {
      'update_cmd' => 'default',
      'update_messages' => 'yes',
      'download_updates' => 'yes',
      'apply_updates' => 'yes',
      'random_sleep' => '360',
      'system_name' => 'None',
      'emit_via' => 'stdio',
      'output_width' => '80',
      'email_from' => 'root@localhost',
      'email_to' => 'root',
      'email_host' => 'localhost',
      'group_list' => 'None',
      'group_package_types' => 'mandatory, default',
      'debuglevel' => '-2',
      'mdpolicy' => 'group:main',
    }
    $options_user=lookup('psick::yum_cron::options', Hash, 'deep', {} )
    $options=merge($options_default,$options_user)

    ::tp::install { 'yum-cron':
      ensure => $ensure,
    }

    if $config_file_template != '' {
      ::tp::conf { 'yum-cron':
        ensure       => $ensure,
        template     => $config_file_template,
        options_hash => $options,
      }
    }
  }
}
