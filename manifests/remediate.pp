# This class manages Puppet remediate installation
#
# @param compose_yml_source remediate_file_template The path of the template (with erb or epp suffix)
#                           to use for the content of /etc/remediate/config.
#                           If empty or remediate is missing the file is not managed.
# @param state The value of the SELINUX parameter in /etc/remediate/config
# @param type  The value of the SELINUXTYPE parameter in /etc/remediate/config
# @param remediate_dir_source The source of the contents of /etc/remediate dir
#                           (format: puppet:///modules/...)
#                           If empty or remediate is missing the dir is not managed.
# @param remediate_dir_recurse The recurse param of the /etc/remediate dir resource
# @param remediate_dir_force   The force param of the /etc/remediate dir resource
# @param remediate_dir_purge   The purge param of the /etc/remediate dir resource
# @param auto_prereq If to automatically install docker and docker compose, as
#   they are needed prerequisites for Puppet Remediate. If set to false you have
#   to care about their installation in other profiles.
# @param silence_notify Set to true to disable notify resources.
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
class psick::remediate (
  String $compose_yml_source = 'https://storage.googleapis.com/remediate/stable/latest/docker-compose.yml',
  Optional[String] $license_json_source = undef,
  Optional[String] $base_dir = undef,
  String $user               = 'remediate',
  Boolean $user_manage       = true,
  Hash $user_options         = {},
  Optional[String] $admin_password = undef,
  Boolean $swarm_init        = true,
  Boolean $auto_prereq       = true,
  Boolean $silence_notify    = false,

  Boolean $manage            = $::psick::manage,
  Boolean $noop_manage       = $::psick::noop_manage,
  Boolean $noop_value        = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $auto_prereq {
      include psick::docker
      include psick::docker::compose
      Class['psick::docker']
      -> Class['psick::docker::compose']
      -> Exec['docker swarm init remediate']
      -> Exec['docker-compose run remediate']
    }

    if $user_manage {
      psick::users::managed { $user:
        groups => ['docker'],
        *      => $user_options,
      }
    }

    $user_home = psick::get_user_home($user)
    $remediate_dir = pick($base_dir,"${user_home}/remediate")
    psick::tools::create_dir { 'psick::remediate::remediate_dir':
      path  => $remediate_dir,
      owner => $user,
    }
    file { "${remediate_dir}/docker-compose.yml":
      ensure  => present,
      source  => $compose_yml_source,
      owner   => $user,
      require => Psick::Tools::Create_dir['psick::remediate::remediate_dir'],
    }
    if $license_json_source {
      file { "${remediate_dir}/license.json":
        ensure  => present,
        source  => $license_json_source,
        owner   => $user,
        require => Psick::Tools::Create_dir['psick::remediate::remediate_dir'],
      }
    } else {
      if ! $silence_notify {
        notify { 'psick::remediate::license warning':
          message => 'Missing $license_json_source. You need to provide a valid license.json to start the application',
        }
      }
    }
    if $swarm_init {
      exec { 'docker swarm init remediate':
        command => "docker swarm init ; touch ${remediate_dir}/.docker-swarn-init-remediate.lock",
        path    => $::path,
        user    => $user,
        cwd     => $remediate_dir,
        creates => "${remediate_dir}/.docker-swarn-init-remediate.lock",
      }
    }
    exec { 'docker-compose run remediate':
      command  => 'docker-compose run remediate start --license-file license.json', # lint:ignore:140char
      path     => $::path,
      cwd      => $remediate_dir,
      user     => $user,
      provider => 'shell',
      unless   => 'if [[ $(docker ps | grep puppet-discover  | grep healthy | wc -l) < 10 ]] ; then false ; else true ; fi' # lint:ignore:140chars # 10 remediate instances by default (as in 201909),
    }
  }

}
