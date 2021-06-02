# define psick::wordpress::instance
#
# @summary This define creates a single wordpress instance based on Apache,
#   php-fpm and mysql
#
define psick::wordpress::instance (
  Psick::Ensure   $ensure                   = 'present',
  Hash            $options_hash             = {},

  Boolean         $wordpress_manage         = true,
  String          $wordpress_tarball_url    = 'https://wordpress.org/latest.tar.gz',
  Boolean         $wordpress_multisite      = true,
  String          $wordpress_htaccess_template = 'psick/wordpress/htaccess.erb',
  String          $wordpress_wpconfig_template = 'psick/wordpress/wp-config.php.erb',

  Boolean         $db_manage                = true,
  String          $db_name                  = "wordpress_${title}",
  String          $db_user                  = "wordpress_${title}",
  Any             $db_password              = fqdn_rand(1000000000000000,'qazwsxedc'),
  String          $db_host                  = 'localhost',

  Boolean         $web_manage               = true,
  String          $web_base_dir             = '/var/www/html',
  String          $wordpress_sitename       = "${title}.${::domain}",
  String          $wordpress_alias          = "www.${title}.${::domain}",
  String          $web_template             = 'psick/wordpress/httpd.conf.erb',
  String          $web_virtualhost_template = 'psick/wordpress/wordpress.conf.erb',
  Hash            $web_options              = {},
  Hash            $php_modules_hash         = {},
  String          $php_fpm_pool_template    = 'psick/wordpress/php-fpm-pool.conf.erb',
  Boolean         $web_ssl                  = false,
  Optional[Integer] $web_port               = undef,
  Boolean         $ftp_manage               = true,

) {

  $web_server_user  = $::psick::wordpress::web_server_user
  $web_server_group = $::psick::wordpress::web_server_group

  if $wordpress_manage {
    psick::netinstall { "wordpress-${title}":
      url             => $wordpress_tarball_url,
      destination_dir => $web_base_dir,
      extracted_dir   => 'wordpress',
      creates         => "${web_base_dir}/wordpress-${title}",
    }
    exec { "mv ${web_base_dir}/wordpress ${web_base_dir}/wordpress-${title}":
      creates => "${web_base_dir}/wordpress-${title}",
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      require => Psick::Netinstall["wordpress-${title}"],
      before  => Exec["chown -R ${web_server_user}:${web_server_group} ${web_base_dir}/wordpress-${title}"],
    }
    tp::conf { "apache::wp-config.php-${title}":
      ensure  => $ensure,
      path    => "${web_base_dir}/wordpress-${title}/wp-config.php",
      require => Exec["mv ${web_base_dir}/wordpress ${web_base_dir}/wordpress-${title}"],
      owner   => $web_server_user,
      group   => $web_server_group,
    }
    file_line { "wp-config.php-${title}":
      ensure  => $ensure,
      path    => "${web_base_dir}/wordpress-${title}/wp-config.php",
      line    => '<?php',
      require => Tp::Conf["apache::wp-config.php-${title}"],
    }
    file_line { "wp-config.php-${title}-DB_NAME":
      ensure  => $ensure,
      path    => "${web_base_dir}/wordpress-${title}/wp-config.php",
      line    => "define( 'DB_NAME', '${db_name}' );",
      require => Tp::Conf["apache::wp-config.php-${title}"],
      after   => '^<?php',
    }
    file_line { "wp-config.php-${title}-DB_USER":
      ensure  => $ensure,
      path    => "${web_base_dir}/wordpress-${title}/wp-config.php",
      line    => "define( 'DB_USER', '${db_user}' );",
      require => Tp::Conf["apache::wp-config.php-${title}"],
      after   => '^<?php',
    }
    file_line { "wp-config.php-${title}-DB_PASSWORD":
      ensure  => $ensure,
      path    => "${web_base_dir}/wordpress-${title}/wp-config.php",
      line    => "define( 'DB_PASSWORD', '${db_password}' );",
      require => Tp::Conf["apache::wp-config.php-${title}"],
      after   => '^<?php',
    }
    file_line { "wp-config.php-${title}-DB_HOST":
      ensure  => $ensure,
      path    => "${web_base_dir}/wordpress-${title}/wp-config.php",
      line    => "define( 'DB_HOST', '${db_host}' );",
      require => Tp::Conf["apache::wp-config.php-${title}"],
      after   => '^<?php',
    }
    file_line { "wp-config.php-${title}-table_prefix":
      ensure  => $ensure,
      path    => "${web_base_dir}/wordpress-${title}/wp-config.php",
      line    => "\$table_prefix = 'wp_';",
      require => Tp::Conf["apache::wp-config.php-${title}"],
      after   => '^<?php',
    }
    file_line { "wp-config.php-${title}-ABSPATH":
      ensure  => $ensure,
      path    => "${web_base_dir}/wordpress-${title}/wp-config.php",
      line    => "require_once ABSPATH . 'wp-settings.php';",
      require => Tp::Conf["apache::wp-config.php-${title}"],
      after   => '^<?php',
    }

    exec { "chown -R ${web_server_user}:${web_server_group} ${web_base_dir}/wordpress-${title}":
      command => "chown -R ${web_server_user}:${web_server_group} ${web_base_dir}/wordpress-${title}",
      onlyif  => "test $(/usr/bin/find ${web_base_dir}/wordpress-${title} ! -user ${web_server_user} -o ! -group ${web_server_group} | wc -l) -gt 0",
      path    => '/bin:/sbin:/usr/bin:/usr/sbin',
      require => Exec["mv ${web_base_dir}/wordpress ${web_base_dir}/wordpress-${title}"],
    }

    if $wordpress_multisite {
      tp::conf { "apache::htaccess-${title}":
        ensure   => $ensure,
        path     => "${web_base_dir}/wordpress-${title}/.htaccess",
        content  => template($wordpress_htaccess_template),
        require  => Exec["mv ${web_base_dir}/wordpress ${web_base_dir}/wordpress-${title}"],
        owner    => $web_server_user,
        group    => $web_server_group,
        base_dir => 'conf',
      }
    }
  }

  if $web_manage {
    $web_real_port = $web_port ? {
      undef   => $web_ssl ? {
        true  => 443,
        false => 80,
      },
      default => $web_port,
    }
    $apache_options_hash = {
      'ServerAdmin'  => "webmaster@${facts['domain']}",
      'DocumentRoot' => "${web_base_dir}/wordpress-${title}",
      'ServerName'   => $wordpress_sitename,
      'ServerAlias'  => $wordpress_alias,
      'port'         => $web_real_port,
      'web_ssl'      => $web_ssl,
    } + $web_options

    tp::conf { "php-fpm::wordpress-${title}.conf":
      ensure   => $ensure,
      content  => template($php_fpm_pool_template),
      base_dir => 'conf',
    }
    tp::conf { "apache::wordpress-${title}.conf":
      ensure       => $ensure,
      template     => $web_virtualhost_template,
      options_hash => $apache_options_hash,
      base_dir     => 'conf',
    }
  }

  if $db_manage {
    psick::mariadb::grant { "wordpress-${title}":
      user       => $db_user,
      password   => $db_password,
      db         => $db_name,
      create_db  => true,
      privileges => 'ALL',
      host       => $db_host,
    }
  }
}
