# This class manages the installation and initialisation of icingaweb2
#
# @param ensure If to install or remove icingaweb2
# @param module What module to use to install icingaweb2: psick or icingaweb2
# @param auto_prereq If to automatically install all the prerequisites
#                    resources needed to install Icingaweb2
#                    (used with $module == psick)
# @param template The path of the erb template (as used in template()) to use
#                 to populate the main Icingaweb configuration file.
#                 (used with $module == psick)
# @param options An open hash of options you may use in your template
#                 (used with $module == psick)
# @param tp_conf_hash An open hash of tp::conf resources to manage any icingaweb
#                     related configuration file
#                     (used with $module == psick)
# @param webserver_class What class to use to manage the webserver. No dedicated
#                        class is used if value is empty or undef
# @param dbserver_class What class to use to manage the dbserver. No dedicated
#                       class is used if value is empty or undef
# @param db_backend What database backend to use for icingaweb2. If set,
#                   relevant client packages are installed
# @param fix_php_timezone If to set the timezone as in $::psick::timezone on php.ini
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
class psick::icingaweb2 (
  String                 $ensure          = 'present',
  Enum['psick','icinga'] $module          = 'icinga',
  Boolean                $auto_prereq     = $::psick::auto_prereq,
  Hash                $icingaweb2_params = {},

  Optional[String]       $webserver_class = '::tp_profile::apache',
  Optional[String]       $dbserver_class  = '::tp_profile::mariadb',
  Optional[String]       $template        = undef,
  Hash                   $options         = { },
  Hash                   $tp_conf_hash    = { },

  Boolean $db_manage                      = true,
  Optional[Enum['mysql','mariadb','pgsql']] $db_backend = 'mysql',
  Hash $db_settings                       = {},

  Boolean $director_db_manage             = false,
  Optional[Enum['mysql','mariadb','pgsql']] $director_db_backend = 'mysql',
  Hash $director_db_settings              = {},

  Enum['ini','db'] $config_backend        = 'db',

  Hash $ido_settings                      = lookup('psick::icinga2::ido_settings'),

  Boolean $fix_php_timezone               = true,
  Boolean $install_icingaweb2_selinux     = false,
  Boolean $php_fpm_manage                 = true,
  String $php_fpm_name                    = 'php-fpm',

  Boolean $monitoring_module_manage       = true,
  Hash $monitoring_module_params          = {},

  Boolean $api_user_manage                = true,
  String $api_host                        = pick($::psick::icinga2::master,$clientcert),
  String $api_user                        = 'icingaweb2',
  String $api_password                    = 'icingaweb2apiuser',
  Array $api_user_permissions             = [ 'status/query', 'actions/*', 'objects/modify/*', 'objects/query/*' ],

  Boolean $puppetdb_module_manage         = false,
  Hash $puppetdb_module_params            = {},

  Boolean $director_module_manage         = false,
  Hash $director_module_params            = {},

  Boolean $grafana_module_manage          = true,
  Hash $grafana_module_params             = {},
  Hash $influxdb_settings                 = lookup('psick::icinga2::influxdb_settings'),

  Boolean $grafana_manage                 = true,
  Hash $grafana_params                    = {},
  Hash $grafana_settings                  = {},

  Hash $extra_modules                     = { },

  Boolean $git_manage                     = true,

  Boolean          $manage               = $::psick::manage,
  Boolean          $noop_manage          = $::psick::noop_manage,
  Boolean          $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    if $webserver_class and $webserver_class != '' {
      contain $webserver_class
      Class['icingaweb2'] ~> Class[$webserver_class]
    }
    if $dbserver_class and $dbserver_class != '' {
      contain $dbserver_class
      Class[$dbserver_class] -> Psick::Mariadb::Grant<||>
      Class[$dbserver_class] -> Psick::Mysql::Grant<||>
    }

    case $module {
      'psick': {
        ::tp::install { 'icingaweb2' :
          ensure      => $ensure,
          auto_prereq => $auto_prereq,
        }
        if $template {
          ::tp::conf { 'icingaweb2':
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
      }
      'icinga': {
        $db_type = $db_backend ? {
          'mariadb' => 'mysql',
          'mysql'   => 'mysql',
          'pgsql'   => 'pgsql',
        }
        $default_icingaweb2_params = $db_manage ? {
          true  => {
            import_schema  => true,
            db_type        => $db_type,
            db_host        => $db_settings['host'],
            db_username    => $db_settings['user'],
            db_password    => $db_settings['password'],
            config_backend => $config_backend,
          },
          false => {
            config_backend => $config_backend,
          },
        }
        class { '::icingaweb2':
          * => $default_icingaweb2_params + $icingaweb2_params,
        }
        if $auto_prereq and $::osfamily == 'RedHat' {
          tp::install { 'scl':
            before => [ Package['icingaweb2'] , Class['psick::php::fpm'] ],
          }
        }

        if $api_user_manage {
          icinga2::object::apiuser { $api_user:
            password    => $api_password,
            permissions => $api_user_permissions,
            target      => '/etc/icinga2/conf.d/api-users.conf',
          }
        }

        if $monitoring_module_manage {
          $monitoring_module_defaults = {
            ensure            => $ensure,
            ido_type          => $db_type,
            ido_host          => $ido_settings['host'],
            ido_db_name       => $ido_settings['database'],
            ido_db_username   => $ido_settings['user'],
            ido_db_password   => $ido_settings['password'],
            commandtransports => {
              icinga2 => {
                transport => 'api',
                username  => $api_user,
                password  => $api_password,
              }
            }
          }
          class { 'icingaweb2::module::monitoring':
            * => $monitoring_module_defaults + $monitoring_module_params,
          }
        }

        if $puppetdb_module_manage {
          $puppetdb_module_defaults = {
            ensure => $ensure,
            ssl    => 'puppet',
            host   => $servername,
          }
          class { 'icingaweb2::module::puppetdb':
            * => $puppetdb_module_defaults + $puppetdb_module_params,
          }
        }

        if $director_module_manage {
          $director_db_type = $director_db_backend ? {
            'mariadb' => 'mysql',
            'mysql'   => 'mysql',
            'pgsql'   => 'pgsql',
          }
          $director_module_defaults = {
            ensure        => $ensure,
            db_type       => $director_db_type,
            db_host       => $director_db_settings['host'],
            db_name       => $director_db_settings['database'],
            db_username   => $director_db_settings['user'],
            db_password   => $director_db_settings['password'],
            import_schema => true,
            kickstart     => true,
            api_host      => $api_host,
            api_username  => $api_user,
            api_password  => $api_password,
            endpoint      => pick($::psick::icinga2::master,$clientcert),
          }
          class { 'icingaweb2::module::director':
            * => $director_module_defaults + $director_module_params,
          }
        }

        if $grafana_module_manage {
          $grafana_module_defaults = {
            ensure         => $ensure,
            git_repository => 'https://github.com/Mikesch-mp/icingaweb2-module-grafana',
            git_revision   => 'master',
            settings       => {},
          }
          icingaweb2::module { 'grafana':
            * => $grafana_module_defaults + $grafana_module_params,
          }
          if $grafana_manage {
            $grafana_defaults = {
              ensure          => $ensure,
              dashboards_hash => {
                'icinga2-default.json' => {
                  ensure   => $ensure,
                  template => undef,
                  source   => 'file:///etc/icingaweb2/enabledModules/grafana/dashboards/influxdb/icinga2-default.json',
                  editable => 'true', # lint:ignore:quoted_booleans
                  require  => Icingaweb2::Module['grafana'],
                },
                'base-metrics.json' => {
                  ensure   => $ensure,
                  template => undef,
                  source   => 'file:///etc/icingaweb2/enabledModules/grafana/dashboards/influxdb/base-metrics.json',
                  editable => 'true', # lint:ignore:quoted_booleans
                  require  => Icingaweb2::Module['grafana'],
                },
              },
              datasources_hash => {
                'DS_ICINGA2' => {
                  ensure           => $ensure,
                  file_name        => 'ds_icinga2.yaml',
                  template         => 'psick/grafana/datasource.yaml.erb',
                  type             => 'influxdb',
                  access           => 'proxy',
                  org_id           => '1',
                  database         => $influxdb_settings['database'],
                  user             => $influxdb_settings['user'],
                  url              => "http://${influxdb_settings['host']}:${influxdb_settings['port']}",
                  basic_authuser   => $grafana_settings['user'],
                  secure_json_data => {
                    password          => $influxdb_settings['password'],
                    basicAuthPassword => $grafana_settings['password'],
                  }
                }
              }
            }
            class { 'psick::grafana':
              * => $grafana_defaults + $grafana_params,
            }
            psick::grafana::user { $grafana_settings['user']:
              name           => $grafana_settings['user'],
              password       => $grafana_settings['password'],
              host           => $grafana_settings['host'],
              port           => $grafana_settings['port'],
              protocol       => $grafana_settings['protocol'],
              email          => $grafana_settings['email'],
              admin_user     => $grafana_settings['admin_user'],
              admin_password => $grafana_settings['admin_password'],
            }
          }
        }

        if $git_manage {
          include ::psick::git
        }
        $extra_modules.each |$k,$v| {
          class { "::icingaweb2::module::${k}":
            * => $v,
          }
        }
      }
      default: {}
    }

    if $db_manage {
      case $db_backend {
        'mariadb': {
          psick::mariadb::grant { 'icingaweb2':
            user       => $db_settings['user'],
            password   => $db_settings['password'],
            db         => $db_settings['database'],
            create_db  => $db_settings['create_db'],
            privileges => $db_settings['grant'],
            host       => $db_settings['host'],
            before     => Package['icingaweb2'],
          }
        }
        'mysql': {
          psick::mysql::grant { 'icingaweb2':
            user       => $db_settings['user'],
            password   => $db_settings['password'],
            db         => $db_settings['database'],
            create_db  => $db_settings['create_db'],
            privileges => $db_settings['grant'],
            host       => $db_settings['host'],
            before     => Package['icingaweb2'],
          }
        }
        'pgsql': {
          # puppetlabs-postgres module required
          postgresql::server::db { $db_settings['database']:
            user     => $db_settings['user'],
            password => postgresql_password($db_settings['user'], $db_settings['password']),
            before   => Package['icingaweb2'],
          }
        }
        default: { }
      } # END case $db_backend
    } # END if $db_manage 


    if $director_db_manage and $director_module_manage {
      case $director_db_backend {
        'mariadb': {
          psick::mariadb::grant { 'director_icingaweb2':
            user       => $director_db_settings['user'],
            password   => $director_db_settings['password'],
            db         => $director_db_settings['database'],
            create_db  => $director_db_settings['create_db'],
            privileges => $director_db_settings['grant'],
            host       => $director_db_settings['host'],
            before     => Package['icingaweb2'],
          }
        }
        'mysql': {
          psick::mysql::grant { 'director_icingaweb2':
            user       => $director_db_settings['user'],
            password   => $director_db_settings['password'],
            db         => $director_db_settings['database'],
            create_db  => $director_db_settings['create_db'],
            privileges => $director_db_settings['grant'],
            host       => $director_db_settings['host'],
            before     => Package['icingaweb2'],
          }
        }
        'pgsql': {
          # puppetlabs-postgres module required
          postgresql::server::db { $director_db_settings['database']:
            user     => $director_db_settings['user'],
            password => postgresql_password($director_db_settings['user'], $director_db_settings['password']),
            before   => Package['icingaweb2'],
          }
        }
        default: { }
      } # END case $diretor_db_backend
    } # END if $director_db_manage 

    if $db_backend {
      $camel_db_backend = $db_backend ? {
        'mariadb' => 'Mysql',
        'mysql'   => 'Mysql',
        'pgsql'   => 'Pgsql',
      }
      $zend_package_require = $::osfamily ? {
        'RedHat' => Tp::Install['epel'],
        default  => undef,
      }
      package { "php-ZendFramework-Db-Adapter-Pdo-${camel_db_backend}":
        before  => Package['icingaweb2'],
        require => $zend_package_require,
      }
    }

    if $fix_php_timezone {
      augeas { 'php_date_timezone':
        context => '/files/etc/php.ini/DATE',
        changes => [
          "set date.timezone ${::psick::timezone}",
        ],
      }
    }
    if $::selinux and $install_icingaweb2_selinux {
      package { 'icingaweb2-selinux':
        ensure  => $ensure,
        require => Class['icinga2'],
      }
    }

    if $php_fpm_manage {
      class { 'psick::php::fpm':
        package_name => $php_fpm_name,
        service_name => $php_fpm_name,
        subscribe    => Class['icingaweb2'],
      }

    }
  }
}
