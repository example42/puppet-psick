# This class manages the installation and initialisation of rundeck
#
# @param ensure If to install or remove rundeck
# @param auto_prereq If to automatically install all the prerequisites
#                    resources needed to install rundeck, if defined in tinydata
# @param template The path to the erb template (as used in template()) to use
#                 to populate the main configuration file.
# @param init_template The path to the erb template (as used in template()) to use
#                      to populate the init script configuration file
# @param options An open hash of options you may use in your template
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
class psick::rundeck (
  String           $ensure        = 'present',
  Boolean          $auto_prereq   = $::psick::auto_prereq,
  Optional[String] $template      = undef,
  Optional[String] $init_template = undef,
  Hash             $options       = { },

  Boolean          $manage        = $::psick::manage,
  Boolean          $noop_manage   = $::psick::noop_manage,
  Boolean          $noop_value    = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $options_default = {
      'framework.server.name'     => $::fqdn,
      'framework.server.hostname' => $::fqdn,
      'framework.server.port'     => '4440',
      'framework.server.url'      => "http://${::fqdn}:4440",
      'framework.ssh.keypath'     => '/var/lib/rundeck/.ssh/id_rsa',
      'framework.ssh.user'        => 'rundeck',
      'framework.ssh.timeout'     => '0',
    }
    $real_options = $options_default + $options

    ::tp::install { 'rundeck' :
      ensure      => $ensure,
      auto_prereq => $auto_prereq,
    }

    if $template {
      ::tp::conf { 'rundeck':
        ensure       => $ensure,
        template     => $template,
        base_file    => 'config',
        options_hash => $real_options,
      }
    }
    if $init_template {
      ::tp::conf { 'rundeck::init':
        ensure       => $ensure,
        template     => $init_template,
        base_file    => 'init',
        options_hash => $real_options,
      }
    }
  }
}
