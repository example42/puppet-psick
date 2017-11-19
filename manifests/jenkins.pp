# @class jenkins
#
class psick::jenkins (

  Variant[Boolean,String]    $ensure     = 'present',
  Enum['psick']              $module     = 'psick',

  Hash                       $plugins    = {},

  Optional[String] $ssh_private_key_content = undef,
  Optional[String] $ssh_public_key_content  = undef,
  Optional[String] $ssh_private_key_source  = undef,
  Optional[String] $ssh_public_key_source   = undef,

  Boolean $ssh_keys_generate                = false,
  String $home_dir                          = '/var/lib/jenkins',

  Optional[String] $scm_sync_repository_url  = undef,
  Optional[String] $scm_sync_repository_host = undef,
) {

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
  or $ssh_public_key_source {
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
