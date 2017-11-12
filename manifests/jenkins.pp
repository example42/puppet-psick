# @class jenkins
#
class psick::jenkins (

  Variant[Boolean,String]    $ensure     = 'present',
  Enum['psick']              $module     = 'psick',

  Hash                       $plugins    = {},

  Optional[String] $ssh_private_key_content = undef,
  Optional[String] $ssh_public_key_content  = undef,
  Boolean $ssh_keys_generate                = false,
  String $home_dir                          = '/var/lib/jenkins',

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
  or $ssh_public_key_content {
    $dir_ensure = ::tp::ensure2dir($ensure)
    file { "${home_dir}/.ssh" :
      ensure  => $dir_ensure,
      mode    => '0700',
      owner   => 'jenkins',
      group   => 'jenkins',
      require => Package['jenkins'],
    }
  }

  if $ssh_keys_generate {
    psick::openssh::keygen { 'jenkins':
      require => File["${home_dir}/.ssh"],
      home    => $home_dir,
    }
  }

  if $ssh_private_key_content {
    file { "${home_dir}/.ssh/id_rsa" :
      ensure  => $ensure,
      mode    => '0600',
      owner   => 'jenkins',
      group   => 'jenkins',
      content => $ssh_private_key_content,
    }
  }

  if $ssh_public_key_content {
    file { "${home_dir}/.ssh/id_rsa.pub" :
      ensure  => $ensure,
      mode    => '0644',
      owner   => 'jenkins',
      group   => 'jenkins',
      content => $ssh_public_key_content,
    }
  }
}
