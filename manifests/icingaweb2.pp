# This class manages the installation and initialisation of icingaweb2
#
# @param ensure If to install or remove icingaweb2
# @param manage If to actually manage any resource in this profile or not
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
# @param no_noop Set noop metaparameter to false to all the resources of this class.
#   This overrides client site noop setting but not $psick::noop_mode.
#
class psick::icingaweb2 (
  String                 $ensure          = 'present',
  Boolean                $manage          = $::psick::manage,
  Enum['psick','icinga'] $module          = 'psick',
  Boolean                $auto_prereq     = $::psick::auto_prereq,

  Optional[String]       $webserver_class = '::psick::apache::tp',
  Optional[String]       $dbserver_class  = '::psick::mariadb::tp',
  Optional[String]       $template        = undef,
  Hash                   $options         = { },
  Hash                   $tp_conf_hash    = { },

  Optional[Enum['mysql','pgsql']] $db_backend = 'mysql',
  Boolean $fix_php_timezone               = true,
  Boolean $install_icingaweb2_selinux     = false,
  Boolean $php_fpm_manage                 = true,
  String $php_fpm_service_name            = 'php-fpm',
  Boolean $no_noop                        = false,
) {

  if $manage {
    if !$::psick::noop_mode and $no_noop {
      info('Forced no-noop mode in psick::icingaweb2')
      noop(false)
    }
    if $webserver_class and $webserver_class != '' {
      contain $webserver_class
    }
    if $dbserver_class and $dbserver_class != '' {
      contain $dbserver_class
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
        contain ::icingaweb2
        if $auto_prereq and $::osfamily == 'RedHat' {
          tp::install { 'scl':
            before => Package['icingaweb2'],
          }
        }
      }
      default: {}
    }

    if $db_backend {
      $camel_db_backend = $db_backend ? {
        'mysql' => 'Mysql',
        'pgsql' => 'Pgsql',
      }
      package { "php-ZendFramework-Db-Adapter-Pdo-${camel_db_backend}":
        before => Package['icingaweb2'],
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
        ensure       => $ensure,
      }
    }

    if $php_fpm_manage {
      service { $php_fpm_service_name:
        ensure => psick::ensure2service($ensure,'ensure'),
        enable => psick::ensure2service($ensure,'enable'),
        before => Package['icingaweb2'],
      }
    }
  }
}
