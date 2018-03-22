# define psick::openssh::keypair
#
# @summary manages ssh keypairs, by providing source or content 
#
define psick::openssh::keypair (

  Variant[Boolean,String]    $ensure        = 'present',
  Optional[String] $user                    = $title,

  Optional[String] $private_key_content     = undef,
  Optional[String] $private_key_source      = undef,

  Optional[String] $public_key_content      = undef,
  Optional[String] $public_key_source       = undef,

  Optional[String] $dir_path                = undef,
  String $dir_path_mode                     = '0700',
  String $key_name                          = 'id_rsa',

) {

  $ssh_dir_path = $dir_path ? {
    undef   => $user ? {
      'root'  => "/${user_real}/.ssh",
      default => "/home/${user_real}/.ssh",
    },
    default => $dir_path,
  }

  # SSH keys management
  if $private_key_content
  or $public_key_content
  or $private_key_source
  or $public_key_source {
    if !defined(File[$ssh_dir_path]) {
      $dir_ensure = ::tp::ensure2dir($ensure)
      file { $ssh_dir_path:
        ensure => $dir_ensure,
        mode   => $dir_path_mode,
      }
    }
  }

  if $private_key_content or $private_key_source {
    file { "${ssh_dir_path}/${key_name}" :
      ensure  => $ensure,
      content => $private_key_content,
      source  => $private_key_source,
    }
  }

  if $public_key_content or $public_key_source {
    file { "${ssh_dir_path}/${key_name}.pub" :
      ensure  => $ensure,
      content => $public_key_content,
      source  => $public_key_source,
    }
  }

}

