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

  Array $client_features = ['api','checker','mainlog'],
  Array $server_features = ['api','checker','mainlog','notification','statusdata','compatlog','command'],

  Boolean         $ido_manage          = true,
  Enum['mariadb','mysql','pgsql'] $ido_backend = 'mariadb',
  Hash            $ido_db_settings     = {},

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
      }
      'icinga': {
        if $is_server == true {
          $features = $server_features
        } else {
          $features = $client_features
        }
        class { icinga2:
          features => $features,
        }

        if $ido_manage and $is_server {
          case $ido_backend {
            'mysql': {
              class{ '::icinga2::feature::idomysql':
                user          => $ido_db_settings['user'],
                password      => $ido_db_settings['password'],
                database      => $ido_db_settings['database'],
                import_schema => true,
                require       => Psick::Mysql::Grant['icinga2'],
              }
            }
            'mariadb': {
              class{ '::icinga2::feature::idomysql':
                user          => $ido_db_settings['user'],
                password      => $ido_db_settings['password'],
                database      => $ido_db_settings['database'],
                import_schema => true,
                require       => Psick::Mariadb::Grant['icinga2'],
              }
            }
            'pgsql': {
              class{ '::icinga2::feature::idopgsql':
                user          => $ido_db_settings['user'],
                password      => $ido_db_settings['password'],
                database      => $ido_db_settings['database'],
                import_schema => true,
                require       => Postgresql::Server::Db[$ido_db_settings['database']],
              }
            }
            default: {}
          }
        }
      }
      default: {}
    }

    if $ido_manage and $is_server {
      case $ido_backend {
        'mariadb': {
          psick::mariadb::grant { 'icinga2':
            user       => $ido_db_settings['user'],
            password   => $ido_db_settings['password'],
            db         => $ido_db_settings['database'],
            create_db  => $ido_db_settings['create_db'],
            privileges => $ido_db_settings['grant'],
            host       => $ido_db_settings['host'],
          }
        }
        'mysql': {
          psick::mysql::grant { 'icinga2':
            user       => $ido_db_settings['user'],
            password   => $ido_db_settings['password'],
            db         => $ido_db_settings['database'],
            create_db  => $ido_db_settings['create_db'],
            privileges => $ido_db_settings['grant'],
            host       => $ido_db_settings['host'],
          }
        }
        'pgsql': {
          # puppetlabs-postgres module required
          postgresql::server::db { $ido_db_settings['database']:
            user     => $ido_db_settings['user'],
            password => postgresql_password($ido_db_settings['user'], $ido_db_settings['password']),
          }
        }
        default: { }
      }

    }
  }
}
