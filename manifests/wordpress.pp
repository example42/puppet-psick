# psick::wordpress
#
# @summary This psick profile manages wordpress
#
# @example Include it to install wordpress
#   include psick::wordpress
#
# @example Include in PSICK via hiera (yaml)
#   psick::profiles::linux_classes:
#     wordpress: psick::wordpress
#
# @param manage If to actually manage any resource in this profile or not
# @param auto_prereq If to automatically install eventual dependencies.
#   Set to false if you have problems with duplicated resources, being sure that you
#   provide the needed prerequistes (apahce, php, mysql...)
# @param options_hash An custom hash of keypair which may be used in templates to
#   manage any wordpress setting.
# @param module What module to use to manage wordpress.
#   The specified module name, if different, must be added to Puppetfile. Set to undef
#   or an empty string to not include any class.
# @param noop_manage If to use the noop() function for all the resources provided
#   by this class. If this is true the noop function is called with $noop_value argument.
#   This overrides any other noop setting (either set on client's puppet.conf or by noop()
#   function in main psick class).
# @param noop_value The value to pass to noop() function if noop_manage is true.
#   It applies to all the resources (and classes) declared in this class.
#   If true: noop metaparamenter is set to true, resources are not applied
#   If false: noop metaparameter is set to false, any eventual noop setting is overridden
#   and resources are always applied.
#
class psick::wordpress (
  Psick::Ensure   $ensure                   = 'present',
  Boolean         $manage                   = $::psick::manage,
  Boolean         $auto_prereq              = true,
  Hash            $options_hash             = {},

  Boolean         $wordpress_manage         = true,
  String          $wordpress_tarball_url    = 'https://wordpress.org/latest.tar.gz',
  Boolean         $wordpress_multisite      = true,
  String          $wordpress_htaccess_template = 'psick/wordpress/htaccess.erb',
  String          $wordpress_wpconfig_template = 'psick/wordpress/wp-config.php.erb',

  Boolean         $db_manage                = true,
  String          $db_name                  = 'wordpress',
  String          $db_user                  = 'wordpress',
  Any             $db_password              = fqdn_rand(1000000000000000,'qazwsxedc'),
  String          $db_host                  = 'localhost',

  Boolean         $web_manage               = true,
  String          $web_base_dir             = '/var/www/html',
  String          $wordpress_sitename       = "wordpress.${::domain}",
  String          $wordpress_alias          = "www.wordpress.${::domain}",
  String          $web_template             = 'psick/wordpress/httpd.conf.erb',
  String          $web_virtualhost_template = 'psick/wordpress/wordpress.conf.erb',
  Hash            $web_options              = {},

  Boolean         $php_manage               = true,
  Array           $php_tp_installs          = [ 'php', 'php-fpm' ],
  Hash            $php_modules_hash         = {},
  String          $php_fpm_pool_template    = 'psick/wordpress/php-fpm-pool.conf.erb',
  Optional[String] $php_modules_prefix      = 'php-',

  Boolean         $ftp_manage               = true,

  Boolean         $create_default_instance  = true,
  Hash            $instances                = {},

  Boolean         $noop_manage              = $::psick::noop_manage,
  Boolean         $noop_value               = $::psick::noop_value,

) {

  if $manage {

    if $noop_manage {
      noop($noop_value)
    }

    $web_server_user = 'apache'
    $web_server_group = 'apache'

    if $web_manage and $auto_prereq {
      tp::install { 'apache':
        ensure => $ensure,
      }
      tp::conf { 'apache':
        ensure       => $ensure,
        template     => $web_template,
        options_hash => $web_options,
      }
      tp::install { 'mod_ssl':
        ensure => $ensure,
      }
    }

    if $web_manage and $auto_prereq {
      $php_tp_installs.each | $k | {
        tp::install { $k:
          ensure => $ensure,
        }
      }
      $php_modules_defaults = {
        ensure => $ensure,
        prefix => $php_modules_prefix,
      }
      $php_modules_hash.each |$k,$v| {
        psick::php::module { $k:
          * => $php_modules_defaults + $v,
        }
      }
    }

    if $ftp_manage {
      tp::install { 'vsftpd': }
    }

    if $db_manage {
      tp::install { 'mariadb':
        ensure => $ensure,
      }
    }

    $instances_defaults = {
      wordpress_manage => $wordpress_manage,
      wordpress_tarball_url => $wordpress_tarball_url,
      wordpress_multisite => $wordpress_multisite,
      wordpress_htaccess_template => $wordpress_htaccess_template,
      wordpress_wpconfig_template => $wordpress_wpconfig_template,
      db_manage => $db_manage,
      db_host => $db_host,
      web_manage => $web_manage,
      web_base_dir => $web_base_dir,
      web_virtualhost_template => $web_virtualhost_template,
      php_fpm_pool_template => $php_fpm_pool_template,
      ftp_manage => $ftp_manage,
    }

    if $create_default_instance {
      psick::wordpress::instance { 'wordpress':
        * => $instances_defaults,
      }
    }
    $instances.each |$k,$v| {
      psick::wordpress::instance { $k:
        * => $instances_defaults + $v,
      }
    }

  }
}
