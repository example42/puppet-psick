# This profile manages the installation and configuration of icinga2
# via the the upstream Icinga2 module.
# If exposes parameters to allow easy configuration and automation
# on a setup based on icinga client on nodes and icinga server, with
# options to automatically populate, and override, data retrived from
# PuppetDB to build the hosts and services checks.
# It also automatically configures database integration taking care of
# grants and db users.
#
# @param ensure If to install or remove icinga2
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
class psick::icinga2 (
  String          $ensure                  = 'present',

  String           $master                 = "icinga.${::domain}",
  Boolean          $is_client              = true,
  Boolean          $is_server              = false,

  Hash $icinga2_class_params               = {},

  # API feature class is declared directly and should not added to these Arrays
  Boolean $manage_api_feature              = true,
  Hash $icinga2_feature_api_class_params   = {},
  Array $client_features                   = ['checker','mainlog'],
  Array $server_features                   = ['checker','mainlog','notification','command'],

  Boolean    $influxdb_manage              = true,
  Hash       $influxdb_settings            = {},

  Boolean         $ido_manage              = true,
  Enum['mariadb','mysql','pgsql'] $ido_backend = 'mariadb',
  Hash            $ido_settings            = {},

  Boolean $generate_client_zones_file      = true,

  Boolean $puppetdb_hosts_import           = true,
  Boolean $puppetdb_hosts_details_import   = true,
  Boolean $puppetdb_zones_import           = true,
  Hash $puppetdb_hosts_override_hash       = {},
  Hash $puppetdb_zones_override_hash       = {},
  Hash $puppetdb_endpoints_override_hash   = {},
  String $notes_url_prefix                 = "https://${servername}/#/inspect/node/",
  String $notes_url_suffix                 = '/reports',
  String $puppetdb_fact_address            = 'networking.ip',
  String $puppetdb_fact_address6           = 'networking.ip6',
  String $puppetdb_fact_network            = 'network',
  String $puppetdb_fact_role               = 'role',
  String $puppetdb_fact_env                = 'env',

  Hash $config_hash                        = {},

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

  Boolean $manage                          = $::psick::manage,
  Boolean $noop_manage                     = $::psick::noop_manage,
  Boolean $noop_value                      = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    # Declares Icinga class with selected features
    $features = $is_server ? {
      true    => $server_features,
      default => $client_features,
    }
    $default_params = {
      features => $features,
      #      confd    => 'zones.d',
    }
    class { 'icinga2':
      * => $default_params + $icinga2_class_params
    }

    # Handle InfluxDB configuration
    if $influxdb_manage and $is_server {
      if $influxdb_settings['host'] == 'localhost'
      or $influxdb_settings['host'] == '127.0.0.1' {
        $influxdb_service_ensure = 'running'
        $influxdb_service_enable = true
      } else {
        $influxdb_service_ensure = 'stopped'
        $influxdb_service_enable = false
      }

      class { 'tp_profile::influxdb':
        settings_hash => {
          service_ensure => $influxdb_service_ensure,
          service_enable => $influxdb_service_enable,
        },
      }
      Class[tp_profile::influxdb] -> Psick::Influxdb::Database<||>

      psick::influxdb::database { 'icinga2':
        database        => $influxdb_settings['database'],
        server_host     => $influxdb_settings['host'],
        server_port     => $influxdb_settings['port'],
        server_user     => $influxdb_settings['influxdb_user'],
        server_password => $influxdb_settings['influxdb_password'],
      }
      psick::influxdb::user { 'icinga2':
        user            => $influxdb_settings['user'],
        password        => $influxdb_settings['password'],
        database        => $influxdb_settings['database'],
        server_host     => $influxdb_settings['host'],
        server_port     => $influxdb_settings['port'],
        server_user     => $influxdb_settings['influxdb_user'],
        server_password => $influxdb_settings['influxdb_password'],
        require         => Psick::Influxdb::Database['icinga2'],
      }
      psick::influxdb::grant { 'icinga2':
        user            => $influxdb_settings['user'],
        database        => $influxdb_settings['database'],
        server_host     => $influxdb_settings['host'],
        server_port     => $influxdb_settings['port'],
        server_user     => $influxdb_settings['influxdb_user'],
        server_password => $influxdb_settings['influxdb_password'],
        privilege       => $influxdb_settings['grant'],
        require         => Psick::Influxdb::User['icinga2'],
      }
      class { '::icinga2::feature::influxdb':
        host     => $influxdb_settings['host'],
        port     => $influxdb_settings['port'],
        username => $influxdb_settings['user'],
        password => $influxdb_settings['password'],
        database => $influxdb_settings['database'],
        require  => Psick::Influxdb::Grant['icinga2'],
      }
    }

    # Handle IDO configuration
    if $ido_manage and $is_server {
      case $ido_backend {
        'mysql': {
          psick::mysql::grant { 'icinga2':
            user       => $ido_settings['user'],
            password   => $ido_settings['password'],
            db         => $ido_settings['database'],
            create_db  => $ido_settings['create_db'],
            privileges => $ido_settings['grant'],
            host       => $ido_settings['host'],
          }
          class { '::icinga2::feature::idomysql':
            user          => $ido_settings['user'],
            password      => $ido_settings['password'],
            database      => $ido_settings['database'],
            import_schema => true,
            require       => Psick::Mysql::Grant['icinga2'],
          }
        }
        'mariadb': {
          psick::mariadb::grant { 'icinga2':
            user       => $ido_settings['user'],
            password   => $ido_settings['password'],
            db         => $ido_settings['database'],
            create_db  => $ido_settings['create_db'],
            privileges => $ido_settings['grant'],
            host       => $ido_settings['host'],
          }
          class { '::icinga2::feature::idomysql':
            user          => $ido_settings['user'],
            password      => $ido_settings['password'],
            database      => $ido_settings['database'],
            import_schema => true,
            require       => Psick::Mariadb::Grant['icinga2'],
          }
        }
        'pgsql': {
          # puppetlabs-postgres module required
          postgresql::server::db { $ido_settings['database']:
            user     => $ido_settings['user'],
            password => postgresql_password($ido_settings['user'], $ido_settings['password']),
          }
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
    # It's possible to customise via the hiera key psick::icinga2::puppetdb_hosts_override_hash
    # any host entry retrieved via PuppetDB. The above hash should have as
    # first level keys certnames matching the ones retrieved from PuppetDB
    # Values must be valid params of the icinga2::object::host define and
    # are deep merged with the default ones set via psick::icinga2::host_default_params
    if $is_server and ($puppetdb_hosts_import or $puppetdb_zones_import) {
      $nodes_query = 'nodes { deactivated is null }'
      $nodes = puppetdb_query($nodes_query)
      $nodes_list = $nodes.map |$node| { $node['certname'] }
    }
    if $is_server and $puppetdb_hosts_import {
      $nodes_list.each |$k| {
        if $puppetdb_hosts_details_import {
          $nodes_facts_query = "inventory[facts] { trusted.certname = '${k}' }"
          $nodes_facts = puppetdb_query($nodes_facts_query)
          $disks = $nodes_facts[0]['facts']['mountpoints'].map |$kk,$vv| {
            if ! $vv['filesystem'] in ['devtmpfs','hugetlbfs','mqueue','devpts','tmpfs','rpc_pipefs'] {
              { $kk => { 'disk_partions' => $kk, } }
            }
          }
          $puppetdb_params = {
            address      => getvar("nodes_facts.0.facts.${puppetdb_fact_address}"),
            address6     => getvar("nodes_facts.0.facts.${puppetdb_fact_address6}"),
            notes        => "${k} | ${nodes_facts[0][facts][operatingsystem]} ${nodes_facts[0][facts][operatingsystemrelease]}",
            notes_url    => "${notes_url_prefix}${k}${notes_url_suffix}",
            vars         => {
              os         => capitalize($nodes_facts[0]['facts']['kernel']),
              distro     => $nodes_facts[0]['facts']['os']['name'],
              # disks      => $disks,
              network    => getvar("nodes_facts.0.facts.${puppetdb_fact_network}"),
              virtual    => $nodes_facts[0]['facts']['virtual'],
              role       => getvar("nodes_facts.0.facts.${puppetdb_fact_role}"),
              env        => getvar("nodes_facts.0.facts.${puppetdb_fact_env}"),
            }
          }
        } else {
          $puppetdb_params = {}
        }
        $hiera_override = pick ($puppetdb_hosts_override_hash[$k],{} )
        ::icinga2::object::host { $k:
          * => deep_merge($host_default_params,$puppetdb_params,$hiera_override),
        }
      }
    }

    # PuppetDB management of endpoint and zones
    if $is_server and $puppetdb_zones_import {
      $nodes_list.each |$k| {
        $local_zones_params = {
          ensure    => $ensure,
          parent    => 'master',
          endpoints => [ $k ],
        }
        $hiera_zones_override = pick ($puppetdb_zones_override_hash[$k],{} )
        if $k != $master {
          ::icinga2::object::zone { $k:
            * => deep_merge($zone_default_params,$local_zones_params,$hiera_zones_override),
          }
        }

        $local_endpoints_params = {
          ensure => $ensure,
          host   => $k,
        }
        $hiera_endpoints_override = pick ($puppetdb_endpoints_override_hash[$k],{} )
        ::icinga2::object::endpoint { $k:
          * => deep_merge($endpoint_default_params,$local_endpoints_params,$hiera_endpoints_override),
        }
      }
    }

    # Zones configuration on clients and server
    # and API configuration
    if $generate_client_zones_file {
      if $is_server and $puppetdb_zones_import {
        $client_zones_hash = {
          'master' => {
            endpoints => [ $master ],
          }
        }
        $client_endpoints_hash = {}
      } else {
        $client_zones_hash = {
          'master' => {
            endpoints => [ $master ],
          },
          $::fqdn => {
            endpoints => [ $::fqdn ],
            parent    => 'master',
          }
        }
        $client_endpoints_hash = {
          $master => {
            host => $master,
          },
          $::fqdn => {
            host => $::fqdn,
          }
        }
      }
    } else {
      $client_endpoints_hash = undef
      $client_zones_hash = undef
    }

    if $manage_api_feature {
      $icinga2_feature_api_defaults = {
        endpoints       => $client_endpoints_hash,
        zones           => $client_zones_hash,
        pki             => 'puppet',
        accept_config   => true,
        accept_commands => true,
      }
      class { 'icinga2::feature::api':
        * => $icinga2_feature_api_defaults + $icinga2_feature_api_class_params,
      }
    }

    # Configuration files
    $config_hash.each |$k,$v| {
      ::psick::icinga2::config { $k:
        * => $v,
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

  } # END if $manage
}
