# This class manages the installation and initialisation of icinga2
# using tp
#
# @param ensure If to install or remove icinga2
# @param manage If to actually manage any resource in this profile or not
# @param auto_prereq If to automatically install all the prerequisites
#                    resources needed to install Icinga
# @param template The path to the erb template (as used in template()) to use
#                 to populate the main Icinga configuration file.
# @param options An open hash of options you may use in your template
# @param install_icinga_cli If to install the icinga-cli package
# @param install_classic_ui If to install the classic-ui package. To manage the
#                           newer icingaweb2 interface use the psick::icingaweb2
#                           class.
# @param tp_conf_hash An open hash of tp::conf resources to manage any icinga related
#                configuration file
# @param no_noop Set noop metaparameter to false to all the resources of this class.
#   This overrides client site noop setting but not $psick::noop_mode.
#
class psick::icinga2 (
  String          $ensure              = 'present',
  Boolean         $manage              = $::psick::manage,

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
    ensure       => $ensure,
    options_hash => $options,
  }
  $tp_conf_hash.each |$k,$v| {
    ::tp::conf { $k:
      * => $tp_conf_defaults + $v,
    }
  }
  if $install_icinga_cli and $is_server {
    package { 'icingacli':
      ensure => $ensure,
    }
  }
  if $install_classic_ui and $is_server {
    package { 'icinga2-classicui-config':
      ensure => $ensure,
    }
  }

  if $ido_manage and $is_server {
    case $ido_backend {
      'mariadb': {
        psick::mariadb::grant { 'icinga2':
          user       => $ido_settings['user'],
          password   => $ido_settings['password'],
          db         => $ido_settings['database'],
          create_db  => $ido_settings['create_db'],
          privileges => $ido_settings['grant'],
          host       => $ido_settings['host'],
        }
      }
      'mysql': {
        psick::mysql::grant { 'icinga2':
          user       => $ido_settings['user'],
          password   => $ido_settings['password'],
          db         => $ido_settings['database'],
          create_db  => $ido_settings['create_db'],
          privileges => $ido_settings['grant'],
          host       => $ido_settings['host'],
        }
      }
      'pgsql': {
        # puppetlabs-postgres module required
        postgresql::server::db { $ido_settings['database']:
          user     => $ido_settings['user'],
          password => postgresql_password($ido_settings['user'], $ido_settings['password']),
        }
      }
      default: { }
    } # END case $ido_backend
  }
}
