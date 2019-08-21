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
# @param tp_conf_hash An open hash of tp::conf resources to manage any icinga related
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

  Array $client_features = ['api','notification','checker','mainlog'],
  Array $server_features = ['api','checker','mainlog','notification','command'],

  Boolean         $ido_manage              = true,
  Enum['mariadb','mysql','pgsql'] $ido_backend = 'mariadb',
  Hash            $ido_settings            = {},

  Boolean $create_hosts_from_puppetdb      = true,

  Hash $endpoint_hash                      = {},
  Hash $endpoint_default_params            = {},

  Hash $zone_hash                          = {},
  Hash $zone_default_params                = {},

  Hash $apiuser_hash                       = {},
  Hash $apiuser_default_params             = {},

  Hash $checkcommand_hash                  = {},
  Hash $checkcommand_default_params        = {},

  Hash $host_hash                          = {},
  Hash $host_default_params                = {},

  Hash $hostgroup_hash                     = {},
  Hash $hostgroup_default_params           = {},

  Hash $dependency_hash                    = {},
  Hash $dependency_default_params          = {},

  Hash $timeperiod_hash                    = {},
  Hash $timeperiod_default_params          = {},

  Hash $usergroup_hash                     = {},
  Hash $usergroup_default_params           = {},

  Hash $user_hash                          = {},
  Hash $user_default_params                = {},

  Hash $notificationcommand_hash           = {},
  Hash $notificationcommand_default_params = {},

  Hash $notification_hash                  = {},
  Hash $notification_default_params        = {},

  Hash $service_hash                       = {},
  Hash $service_default_params             = {},

  Hash $servicegroup_hash                  = {},
  Hash $servicegroup_default_params        = {},

  Hash $scheduleddowntime_hash             = {},
  Hash $scheduleddowntime_default_params   = {},

  Hash $eventcommand_hash                  = {},
  Hash $eventcommand_default_params        = {},

  Hash $checkresultreader_hash             = {},
  Hash $checkresultreader_default_params   = {},

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
      }
      'icinga': {
        if $is_server == true {
          $features = $server_features
        } else {
          $features = $client_features
        }
        class { 'icinga2':
          features => $features,
        }

        if $ido_manage and $is_server {
          case $ido_backend {
            'mysql': {
              class { '::icinga2::feature::idomysql':
                user          => $ido_settings['user'],
                password      => $ido_settings['password'],
                database      => $ido_settings['database'],
                import_schema => true,
                require       => Psick::Mysql::Grant['icinga2'],
              }
            }
            'mariadb': {
              class { '::icinga2::feature::idomysql':
                user          => $ido_settings['user'],
                password      => $ido_settings['password'],
                database      => $ido_settings['database'],
                import_schema => true,
                require       => Psick::Mariadb::Grant['icinga2'],
              }
            }
            'pgsql': {
              class { '::icinga2::feature::idopgsql':
                user          => $ido_settings['user'],
                password      => $ido_settings['password'],
                database      => $ido_settings['database'],
                import_schema => true,
                require       => Postgresql::Server::Db[$ido_settings['database']],
              }
            }
            default: {}
          }
        }

        # PuppetDB nodes import
        if $create_hosts_from_puppetdb {
          {}.each |$k,$v| {
            $hosts_defaults = {
              target  => '/etc/icinga2/conf.d/hosts.conf',
              import  => [ 'generic-host' ],
              address => '',
            }
            ::icinga2::object::host { $k:
              * => $hosts_defaults,
            }
          }
        }

        # Extra objects
        $endpoint_hash.each |$k,$v| {
          ::icinga2::object::endpoint { $k:
            * => $endpoint_default_params + $v,
          }
        }
        $zone_hash.each |$k,$v| {
          ::icinga2::object::zone { $k:
            * => $zone_default_params + $v,
          }
        }
        $apiuser_hash.each |$k,$v| {
          ::icinga2::object::apiuser { $k:
            * => $apiuser_default_params + $v,
          }
        }
        $checkcommand_hash.each |$k,$v| {
          ::icinga2::object::checkcommand { $k:
            * => $checkcommand_default_params + $v,
          }
        }
        $host_hash.each |$k,$v| {
          ::icinga2::object::host { $k:
            * => $host_default_params + $v,
          }
        }
        $hostgroup_hash.each |$k,$v| {
          ::icinga2::object::hostgroup { $k:
            * => $hostgroup_default_params + $v,
          }
        }
        $dependency_hash.each |$k,$v| {
          ::icinga2::object::dependency { $k:
            * => $dependency_default_params + $v,
          }
        }
        $timeperiod_hash.each |$k,$v| {
          ::icinga2::object::timeperiod { $k:
            * => $timeperiod_default_params + $v,
          }
        }
        $usergroup_hash.each |$k,$v| {
          ::icinga2::object::usergroup { $k:
            * => $usergroup_default_params + $v,
          }
        }
        $user_hash.each |$k,$v| {
          ::icinga2::object::user { $k:
            * => $user_default_params + $v,
          }
        }
        $notificationcommand_hash.each |$k,$v| {
          ::icinga2::object::notificationcommand { $k:
            * => $notificationcommand_default_params + $v,
          }
        }
        $notification_hash.each |$k,$v| {
          ::icinga2::object::notification { $k:
            * => $notification_default_params + $v,
          }
        }
        $service_hash.each |$k,$v| {
          ::icinga2::object::service { $k:
            * => $service_default_params + $v,
          }
        }
        $servicegroup_hash.each |$k,$v| {
          ::icinga2::object::servicegroup { $k:
            * => $servicegroup_default_params + $v,
          }
        }
        $scheduleddowntime_hash.each |$k,$v| {
          ::icinga2::object::scheduleddowntime { $k:
            * => $scheduleddowntime_default_params + $v,
          }
        }
        $eventcommand_hash.each |$k,$v| {
          ::icinga2::object::eventcommand { $k:
            * => $eventcommand_default_params + $v,
          }
        }
        $checkresultreader_hash.each |$k,$v| {
          ::icinga2::object::checkresultreader { $k:
            * => $checkresultreader_default_params + $v,
          }
        }
      }
      default: {}
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
    } # END if $ido_manage and $is_server
  } # END if $manage
}
