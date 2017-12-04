# @class jenkins
#
class psick::jenkins (

  Variant[Boolean,String]    $ensure     = 'present',
  Enum['psick']              $module     = 'psick',

  Hash                       $plugins    = {},

  Hash                       $init_options  = {},

  Optional[String] $ssh_private_key_content = undef,
  Optional[String] $ssh_public_key_content  = undef,
  Optional[String] $ssh_private_key_source  = undef,
  Optional[String] $ssh_public_key_source   = undef,

  Boolean $ssh_keys_generate                = false,
  String $home_dir                          = '/var/lib/jenkins',

  Optional[String] $scm_sync_repository_url  = undef,
  Optional[String] $scm_sync_repository_host = undef,

  Boolean $disable_setup_wizard              = false,
) {

  $java_args_extra = $disable_setup_wizard ? {
    true  => '-Djenkins.install.runSetupWizard=false',
    false => '',
  }

  $default_init_options = {
    'NAME'           => 'jenkins',
    'JAVA'           => '/usr/bin/java',
    'JAVA_ARGS'      => "-Djava.awt.headless=true ${java_args_extra}",
    'PIDFILE'        => '/var/run/$NAME/$NAME.pid',
    'JENKINS_USER'   => '$NAME',
    'JENKINS_GROUP'  => '$NAME',
    'JENKINS_WAR'    => '/usr/share/$NAME/$NAME.war',
    'JENKINS_HOME'   => '/var/lib/$NAME',
    'RUN_STANDALONE' => 'true',
    'JENKINS_LOG'    => '/var/log/$NAME/$NAME.log',
    'MAXOPENFILES'   => '8192',
    'HTTP_PORT'      => '8080',
    'PREFIX'         => '/$NAME',
    'JENKINS_ARGS'   => '--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT',
  }
  $all_init_options = $default_init_options + $init_options

  # Installation management
  case $module {
    'psick': {
      contain ::psick::java
      contain ::psick::jenkins::tp
      $plugins.each |$k,$v| {
        psick::jenkins::plugin { $k:
          require => Package['jenkins'],
          *       => $v,
        }
      }
      tp::conf { 'jenkins::init':
        template     => 'psick/jenkins/init.erb',
        options_hash => $all_init_options,
        base_file    => 'init',
      }
    }
    default: {
      contain ::jenkins
    }
  }

  # SSH keys management
  if $ssh_keys_generate
  or $ssh_private_key_content
  or $ssh_public_key_content
  or $ssh_private_key_source
  or $ssh_public_key_source
  or $scm_sync_repository_host {
    $dir_ensure = ::tp::ensure2dir($ensure)
    file { "${home_dir}/.ssh" :
      ensure  => $dir_ensure,
      mode    => '0700',
      owner   => 'jenkins',
      group   => 'jenkins',
      require => Package['jenkins'],
      before  => Service['jenkins'],
    }
  }

  if $ssh_keys_generate {
    psick::openssh::keygen { 'jenkins':
      require => File["${home_dir}/.ssh"],
      before  => Service['jenkins'],
      home    => $home_dir,
    }
  }

  if $ssh_private_key_content or $ssh_private_key_source {
    file { "${home_dir}/.ssh/id_rsa" :
      ensure  => $ensure,
      mode    => '0600',
      owner   => 'jenkins',
      group   => 'jenkins',
      content => $ssh_private_key_content,
      source  => $ssh_private_key_source,
      before  => Service['jenkins'],
    }
  }

  if $ssh_public_key_content or $ssh_public_key_source {
    file { "${home_dir}/.ssh/id_rsa.pub" :
      ensure  => $ensure,
      mode    => '0644',
      owner   => 'jenkins',
      group   => 'jenkins',
      content => $ssh_public_key_content,
      source  => $ssh_public_key_source,
      before  => Service['jenkins'],
    }
  }

  if $scm_sync_repository_url {
    include ::psick::jenkins::scm_sync
  }

  if $scm_sync_repository_host {
    psick::openssh::config { 'jenkins':
      path         => "${home_dir}/.ssh/config",
      before       => Service['jenkins'],
      options_hash => {
        "Host ${scm_sync_repository_host}" => {
          'StrictHostKeyChecking' => 'no',
          'UserKnownHostsFile'    => '/dev/null',
        }
      }
    }
  }

}
