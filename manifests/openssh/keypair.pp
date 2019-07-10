# define psick::openssh::keypair
#
# @summary manages ssh keypairs, by providing source or content
#
define psick::openssh::keypair (

  Variant[Boolean,String]    $ensure        = 'present',
  Optional[String] $user                    = $title,

  Optional[String] $private_key_content     = undef,
  Optional[String] $private_key_source      = undef,
  Optional[String] $private_key_owner       = undef,
  Optional[String] $private_key_group       = undef,
  Optional[String] $private_key_mode        = '0600',

  Optional[String] $public_key_content      = undef,
  Optional[String] $public_key_source       = undef,
  Optional[String] $public_key_owner        = undef,
  Optional[String] $public_key_group        = undef,
  Optional[String] $public_key_mode         = '0644',

  Optional[String] $dir_path                = undef,
  Optional[String] $dir_owner               = undef,
  Optional[String] $dir_group               = undef,
  Optional[String] $dir_mode                = '0700',

  String $key_name                          = 'id_rsa',
  Boolean $create_ssh_dir                   = true,

) {

  $ssh_dir_path = $dir_path ? {
    undef   => $user ? {
      'root'  => "/${user}/.ssh",
      default => "/home/${user}/.ssh",
    },
    default => $dir_path,
  }

  # SSH keys management
  if $create_ssh_dir {
    psick::tools::create_dir { "openssh_keypair_${ssh_dir_path}_${title}":
      path  => $ssh_dir_path,
      owner => pick($dir_owner,$user),
      group => pick($dir_group,$user),
    }
  }

  if $private_key_content or $private_key_source {
    file { "${ssh_dir_path}/${key_name}" :
      ensure  => $ensure,
      owner   => pick($private_key_owner,$user),
      group   => pick($private_key_group,$user),
      mode    => $private_key_mode,
      content => $private_key_content,
      source  => $private_key_source,
    }
    if $create_ssh_dir {
      Psick::Tools::Create_dir["openssh_keypair_${ssh_dir_path}_${title}"] -> File["${ssh_dir_path}/${key_name}"]
    }
  }

  if $public_key_content or $public_key_source {
    file { "${ssh_dir_path}/${key_name}.pub" :
      ensure  => $ensure,
      owner   => $public_key_owner,
      group   => $public_key_group,
      mode    => $public_key_mode,
      content => $public_key_content,
      source  => $public_key_source,
    }
    if $create_ssh_dir {
      Psick::Tools::Create_dir["openssh_keypair_${ssh_dir_path}_${title}"] -> File["${ssh_dir_path}/${key_name}.pub"]
    }
  }
}
