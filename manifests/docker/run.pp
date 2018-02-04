# @define psick::docker::run
#
# This define manages and runs a container based on the given docker image
# Derived from https://github.com/garethr/garethr-docker/blob/master/manifests/run.pp
#
define psick::docker::run (

  String[1]               $ensure              = 'running',

  Variant[Undef,String]   $image               = '',
  String                  $command             = '',

  String                  $username            = '',
  Variant[Undef,String]   $repository          = $title,
  Variant[Undef,String]   $repository_tag      = undef,

  String                  $container_name      = $title,

  Pattern[/service|command/] $run_mode         = 'command',
  String                     $run_options      = '',
  String                     $service_prefix   = 'docker-',

  Boolean                 $remove_container_on_start = true,
  Boolean                 $remove_container_on_stop  = true,
  Boolean                 $remove_volume_on_start    = true,
  Boolean                 $remove_volume_on_stop     = true,

  Variant[Undef,Array]    $exec_environment    = undef,
  Variant[Boolean,Pattern[/on_failure/]] $exec_logoutput = 'on_failure',

  Variant[Undef,String]   $init_template       = undef,

  Boolean                 $mount_data_dir      = true,
  Boolean                 $mount_log_dir       = true,

  Hash                    $settings            = { },

  ) {

  $sanitised_title = $title
  # $sanitised_title = regsubst($title, '/', '-', 'G')

  $username_prefix = $username ? {
    ''      => $::psick::docker::username ? {
      ''      => '',
      default => "${::psick::docker::username}/",
    },
    default => "${username}/",
  }
  $title_elements = split ($title, '::')
  $app = $title_elements[0]
  #  $tp_app_settings = tp_lookup($app,'settings',$::psick::docker::tinydata_module,'merge')
  # $app_settings = $tp_app_settings + $settings

  $real_image = $image ? {
    ''      => "${username_prefix}/${repository}:${repository_tag}",
    default => $image,
  }

  if $run_mode == 'command' {
    Exec {
      path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin',
      timeout     => 3000,
      environment => $exec_environment,
      logoutput   => $exec_logoutput,
    }

    $cidfile = "/var/run/${service_prefix}${sanitised_title}.cid"
    $exec_command = $ensure ? {
      'running' => "docker run -d ${run_options} --name ${sanitised_title} --cidfile=${cidfile} ${real_image} ${command}",
      'present' => "docker run -d ${run_options} --name ${sanitised_title} --cidfile=${cidfile} ${real_image} ${command}",
      'stopped' => "docker stop ${sanitised_title}",
      'absent'  => "docker stop ${sanitised_title} ; docker rm ${sanitised_title}",
    }
    $exec_unless = $ensure ? {
      'running' => "docker ps --no-trunc | grep `cat ${cidfile}`",
      'present' => "docker ps --no-trunc | grep `cat ${cidfile}`",
      'stopped' => "docker ps --no-trunc | grep `cat ${cidfile}` || true",
      'absent'  => "docker ps --no-trunc | grep `cat ${cidfile}` || true",
    }
    exec { "docker run ${sanitised_title}":
      command => $exec_command,
      unless  => $exec_unless,
    }
  }

  if $run_mode == 'service' {
    $service_ensure = $ensure ? {
      'absent' => 'stopped',
      false    => 'stopped',
      default  => 'running',
    }
    $service_enable = $ensure ? {
      'absent' => false,
      false    => false,
      default  => true,
    }
    case $::psick::docker::module_settings['init_system'] {
      'upstart': {
        $initscript_file_path = "/etc/init/${service_prefix}${sanitised_title}.conf"
        $default_template = 'psick/docker/run/upstart.erb'
        $init_file_mode = '0644'
        $service_provider = 'upstart'
      }
      'systemd': {
        $initscript_file_path = "/etc/systemd/system/${service_prefix}${sanitised_title}.service"
        $default_template = 'psick/docker/run/systemd.erb'
        $init_file_mode = '0644'
        $service_provider = 'systemd'
      }
      'sysvinit': {
        $initscript_file_path = "/etc/init.d/${service_prefix}${sanitised_title}"
        $default_template = 'psick/docker/run/sysvinit.erb'
        $init_file_mode = '0755'
        $service_provider = undef
      }
      default: {
        fail('Unknow init system check $::psick::docker::module_settings[init_system]')
      }
    }

    file { $initscript_file_path:
      ensure  => $ensure,
      content => template(pick($init_template,$default_template)),
      mode    => $init_file_mode,
      notify  => Service["docker-${app}"],
    }
    service { "${service_prefix}${sanitised_title}":
      ensure   => $service_ensure,
      enable   => $service_enable,
      provider => $service_provider,
      require  => Service[$::psick::docker::module_settings['service_name']],
    }
  }
}
