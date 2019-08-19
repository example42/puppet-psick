# This class manages the installation and initialisation of icinga2
# Its possible to manage the installation method via the $module param:
#   - psick : Install icinga2 via Tiny Puppet
#   - icinga: Install icinga2 via the upstream Icinga2 module
#
# @param ensure If to install or remove icinga2
# @param manage If to actually manage any resource in this profile or not
# @param module What module to use to install icinga2: psick or icinga2
# @param auto_prereq If to automatically install all the prerequisites
#                    resources needed to install Icinga
#                    (used with $module == psick)
# @param template The path to the erb template (as used in template()) to use
#                 to populate the main Icinga configuration file.
#                 (used with $module == psick)
# @param options An open hash of options you may use in your template
#                 (used with $module == psick)
# @param install_icinga_cli If to install the icinga-cli package
#                 (used with $module == psick)
# @param install_classic_ui If to install the classic-ui package. To manage the
#                           newer icingaweb2 interface use the psick::icingaweb2
#                           class.
#                           (used with $module == psick)
# @param options An open hash of tp::conf resources to manage any icinga related
#                configuration file
#                (used with $module == psick)
# @param no_noop Set noop metaparameter to false to all the resources of this class.
#   This overrides client site noop setting but not $psick::noop_mode.
#
class psick::icinga2 (
  String          $ensure              = 'present',
  Boolean         $manage              = $::psick::manage,
  Enum['psick','icinga'] $module       = 'psick',

  Boolean          $auto_prereq        = $::psick::auto_prereq,
  Optional[String] $template           = undef,
  Hash             $options            = { },
  Boolean          $install_icinga_cli = false,
  Boolean          $install_classic_ui = false,
  Hash             $tp_conf_hash       = { },

  String           $master             = "icinga.${::domain}",
  Boolean          $is_client          = true,
  Boolean          $is_server          = false,

  Boolean         $no_noop             = false,
) {

  if $manage {
    if !$::psick::noop_mode and $no_noop {
      info('Forced no-noop mode in psick::icinga2')
      noop(false)
    }
    # Installation management
    case $module {
      'psick': {
        ::tp::install { 'icinga2' :
          ensure      => $ensure,
          auto_prereq => $auto_prereq,
        }
        if $template {
          ::tp::conf { 'icinga2':
            ensure       => $ensure,
            template     => $template,
            base_dir     => 'conf',
            options_hash => $options,
          }
        }
        $tp_conf_defaults = {
          ensure        => $ensure,
          options_hash  => $options,
        }
        $tp_conf_hash.each |$k,$v| {
          ::tp::conf { $k:
            * => $tp_conf_defaults + $v,
          }
        }
        if $install_icinga_cli {
          package { 'icingacli':
            ensure => $ensure,
          }
        }
        if $install_classic_ui {
          package { 'icinga2-classicui-config':
            ensure => $ensure,
          }
        }
      }
      'icinga': {
        contain ::icinga2
      }
      default: {}
    }
  }
}
