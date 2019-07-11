# @summary This define creates a bolt project directory.
#
# It allows to customise the contents of all the relevant files
# and it can be integrated over a Puppet control-repo, to clone
# from a given $control_repo_url.
# By default everything is cretaed in a directory called Boltdir in
# the home passed as title. It's possible to specify a different $user
# (using whatever title) or a different destination $path 
#
# @example Create a bolt project in /home/al/Boltdir (on *nix)
# 
#   psick::bolt::project { 'al': }
#
# @example Create a bolt project in /opt/admins/bolt-control-center as user admin
#   
#   psick::bolt::project { 'control-center':
#     user => 'admin',
#     path => '/opt/admins/bolt-control-center',
#   }
#
# @example Create a bolt project in /home/al/psick based on psick control-repo
#
#   psick::bolt::project { 'al':
#     path                   => '/home/al/psick',
#     control_repo_integrate => true,
#   }
#
# @example Create a bolt project in /home/al/Boltdir based on pa custom control-repo
#
#   psick::bolt::project { 'al':
#     control_repo_integrate => true,
#     control_repo_url       => 'https://git.example/puppet/control-repo',
#   }
#
define psick::bolt::project (

  Psick::Ensure $ensure                = 'present',
  String $user                         = $title,
  Optional[String] $group              = undef,
  String $mode                         = '0640',
  Boolean $replace                     = true,

  Boolean $user_manage                 = false,
  Hash $user_options_hash              = {}, # Hash of options for psick::users::managed

  Optional[Stdlib::Absolutepath] $path = undef,

  Boolean $use_default_config_files_hash = true,
  Hash $config_files_hash                = {},

  Optional[String] $bolt_yaml_template      = 'psick/bolt/project/bolt.yaml.epp',
  Optional[String] $inventory_yaml_template = undef,
  Hash $options_hash                        = {},

  Optional[String] $data_repo_url = undef,

  Boolean $control_repo_integrate = false,
  Psick::Url $control_repo_url    = 'https://github.com/example42/psick',

  Boolean $puppetfile_install = false,

) {

  $home_dir = pick($path, psick::get_user_home($user))
  $bolt_dir = "${home_dir}/Boltdir"

  File {
    ensure  => $ensure,
    owner   => $user,
    group   => $group,
    mode    => $mode,
    replace => $replace,
    require => $control_repo_integrate ? {
      true  => Tp::Dir[$bolt_dir],
      false => undef,
    }
  }

  if $control_repo_integrate {
    tp::dir { $bolt_dir:
      ensure  => $ensure,
      source  => $control_repo_url,
      vcsrepo => 'git',
    }
  } else {
    file { $bolt_dir:
      ensure => tp::ensure2dir($ensure)
    }
  }

  $default_config_hash = {
    [ 'modules' , 'site-modules' ] => {
      ensure => tp::ensure2dir($ensure)
    },
    'bolt.yaml' => {
      content => psick::template($bolt_yaml_template),
    },
    'inventory.yaml' => {
      content => psick::template($inventory_yaml_template),
    },
  }

  if $data_repo_url {
    # tp::dir handles file resource data
    tp::dir { "${bolt_dir}/data":
      source  => $data_repo_url,
      vcsrepo => 'git',
    }
    $data_dir_config_hash = { }
  } else {
    if $use_default_config_files_hash {
      $data_dir_config_hash = {
        'data' => {
          ensure => tp::ensure2dir($ensure)
        }
      }
    } else {
      $data_dir_config_hash = { }
    }
  }

  if $user_manage {
    user { $user:
      * => $user_options_hash,
    }
  }

  $all_files_hash = $use_default_config_files_hash ? {
    true  => $default_config_hash + $data_dir_config_hash + $config_files_hash,
    false => $data_dir_config_hash + $config_files_hash,
  }

  $all_files_hash.each | $k,$v | {
    file { "${bolt_dir}/${k}":
      * => $v,
    }
  }

  if $puppetfile_install {
    exec { 'bolt install puppetfile':
      path    => $::path,
      cwd     => $bolt_dir,
      creates => 'modules/stdlib', # Quick and very dirty
    }
  }
}
