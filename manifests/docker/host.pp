#
class psick::docker::host (

  Variant[Boolean,String] $ensure              = present,
  Hash                    $instances           = {},

  Variant[Undef,String]   $repository_tag      = 'latest',

  Variant[Undef,Array]    $exec_environment    = [],
  Variant[Boolean,Pattern[/on_failure/]] $exec_logoutput = 'on_failure',

  Pattern[/command|service/] $run_mode         = 'service',
  String                  $run_options         = '',

  Boolean                 $mount_data_dir      = true,
  Boolean                 $mount_log_dir       = true,

  Boolean                $manage               = $::psick::manage,
  Boolean                $noop_manage          = $::psick::noop_manage,
  Boolean                $noop_value           = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    include ::psick::docker

    $instances.each |$instance,$opts| {

      psick::docker::run { $instance:
        ensure           => pick_default($opts['ensure'],$ensure),
        image            => pick_default($opts['image'],''),
        username         => pick_default($opts['username'],$::psick::docker::username),
        repository       => pick_default($opts['repository'],$instance),
        repository_tag   => pick_default($opts['repository_tag'],$repository_tag),
        exec_environment => pick_default($opts['exec_environment'],$exec_environment),
        exec_logoutput   => pick_default($opts['exec_logoutput'],$exec_logoutput),
        run_mode         => pick_default($opts['run_mode'],$run_mode),
        run_options      => pick_default($opts['run_options'],$run_options),
        mount_data_dir   => pick_default($opts['mount_data_dir'],$mount_data_dir),
        mount_log_dir    => pick_default($opts['mount_log_dir'],$mount_log_dir),
      }
    }
  }
}
