# @define psick::docker::tp_build
#
# Build multi OS Docker images using Tiny puppet
#
define psick::docker::tp_build (

  String[1]                              $ensure              = 'present',

  Variant[Undef,String]                  $template            = 'psick/docker/Dockerfile.erb',
  String[1]                              $workdir             = '/var/tmp',

  String                                 $username            = '',

  String                                 $image_name          = '',
  String[1]                              $image_os            = downcase($::operatingsystem),
  String[1]                              $image_osversion     = $::operatingsystemmajrelease,

  Variant[Undef,String]                  $maintainer          = undef,
  String                                 $from                = '',
  Variant[Undef,String]                  $repository          = $title,
  Variant[Undef,String]                  $repository_tag      = 'latest',
  Pattern[/command|supervisor/]          $command_mode        = 'supervisor',
  Array                                  $prepend_lines       = [],
  Array                                  $append_lines        = [],

  Variant[Undef,Array]                   $exec_environment    = undef,
  Variant[Boolean,Pattern[/on_failure/]] $exec_logoutput      = 'on_failure',

  Boolean                                $always_build        = true,
  String                                 $build_options       = '',

  Boolean                                $mount_data_dir      = true,
  Boolean                                $mount_log_dir       = true,

  Boolean                                $copy_data_on_image  = true,
  Hash                                   $conf_hash           = { },
  Hash                                   $dir_hash            = { },

  Hash                                   $settings_hash       = {},

  String[1]       $data_module = pick($::psick::docker::data_module,'tinydata'),

  ) {

  include ::psick::docker

  # Settings evaluation
  $title_elements = split ($title, '::')
  $app = $title_elements[0]
  $tp_settings = tp_lookup($app,'settings',$data_module,'merge')
  $settings_supervisor = tp_lookup('supervisor','settings',$data_module,'merge')
  $settings = $tp_settings + $settings_hash

  $real_from = $from ? {
    ''      => "${image_os}:${image_osversion}",
    default => $from,
  }
  $username_prefix = $username ? {
    ''      => $::docker::username ? {
      ''      => '',
      default => "${::docker::username}/",
    },
    default => "${username}/",
  }
  $basedir_path = "${workdir}/${username_prefix}${image_os}/${image_osversion}/${app}"
  $real_image_name = $image_name ? {
    ''      => "${username_prefix}${repository}:${repository_tag}",
    default => $image_name,
  }

  Exec {
    path    => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin',
    timeout => 3000,
  }

  # Dockerfile creation
  exec { "mkdir -p ${basedir_path}/root":
    creates => "${basedir_path}/root",
  }
  -> file { [ "${basedir_path}/Dockerfile" , "${basedir_path}/root/Dockerfile" ]:
    ensure  => $ensure,
    content => template($template),
  }

  # Extra confs or dirs creation
  $conf_hash.each |$conf_name,$conf_options| {
    tp::conf { "${conf_name}::docker::build":
      ensure              => pick_default($conf_options['ensure'],present),
      source              => pick_undef($conf_options['source']),
      template            => pick_undef($conf_options['template']),
      epp                 => pick_undef($conf_options['epp']),
      content             => pick_undef($conf_options['content']),
      base_dir            => pick_undef($conf_options['base_dir']),
      base_file           => pick_default($conf_options['base_file'],'config'),
      path                => pick_undef($conf_options['path']),
      mode                => pick_undef($conf_options['mode']),
      owner               => pick_undef($conf_options['owner']),
      group               => pick_undef($conf_options['group']),
      path_prefix         => "${basedir_path}/root",
      path_parent_create  => true,
      config_file_notify  => false,
      config_file_require => false,
      options_hash        => pick_default($conf_options['options_hash'],{ }),
      settings_hash       => pick_default($conf_options['settings_hash'],{ } ),
      data_module         => pick_default($conf_options['data_module'],'tinydata'),
      notify              => Exec["docker build ${build_options} -t ${real_image_name} ${basedir_path}"],
    }
  }

  $dir_hash.each |$dir_name,$dir_options| {
    tp::dir { "${dir_name}::docker::build":
      ensure             => pick_default($dir_options['ensure'],present),
      source             => pick_undef($dir_options['source']),
      vcsrepo            => pick_undef($dir_options['vcsrepo']),
      base_dir           => pick_default($dir_options['base_dir'],'config'),
      path               => pick_undef($dir_options['path']),
      mode               => pick_undef($dir_options['mode']),
      owner              => pick_undef($dir_options['owner']),
      group              => pick_undef($dir_options['group']),
      path_prefix        => "${basedir_path}/root",
      path_parent_create => true,
      config_dir_notify  => false,
      config_dir_require => false,
      purge              => pick_default($dir_options['purge'],false),
      recurse            => pick_default($dir_options['recurse'],false),
      force              => pick_default($dir_options['force'],false),
      settings_hash      => pick_default($dir_options['settings_hash'],{ } ),
      data_module        => pick_default($dir_options['data_module'],'tinydata'),
      notify             => Exec["docker build ${build_options} -t ${real_image_name} ${basedir_path}"],
    }
  }

  $exec_refreshonly = $always_build ? {
    true  => false,
    false => true,
  }
  $exec_require = $::docker::install_class ? {
    ''      => undef,
    default => Class[$::docker::install_class],
  }
  exec { "docker build ${build_options} -t ${real_image_name} ${basedir_path}":
    command     => "docker build ${build_options} -t ${real_image_name} ${basedir_path}",
    cwd         => $basedir_path,
    subscribe   => File["${basedir_path}/Dockerfile"],
    environment => $exec_environment,
    logoutput   => $exec_logoutput,
    refreshonly => $exec_refreshonly,
    require     => $exec_require,
  }

}
