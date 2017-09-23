# @define psick::docker::push
#
define psick::docker::push (

  String[1]               $ensure              = 'present',

  String[1]               $username            = $::psick::docker::username,

  Variant[Undef,String]   $repository          = $title,
  Variant[Undef,String]   $repository_tag      = undef,

  Variant[Undef,Array]    $exec_environment    = undef,

  Hash                    $settings_hash       = {},

  String[1]               $data_module         = $::psick::docker::data_module,

  ) {

  Exec {
    path    => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin',
    timeout => 3000,
  }

  if $ensure == 'present' {
    exec { "docker push ${username}/${repository}:${repository_tag}":
      environment => $exec_environment,
    }
  }

}
