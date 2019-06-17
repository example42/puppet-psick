# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   psick::bolt::project { 'al': }
define psick::bolt::project (

  Psick::Ensure $ensure                = 'present',
  String $user                         = $title,
  Optional[String] $group              = undef,
  String $mode                         = '0640',
  Boolean $replace                     = true,

  Optional[Stdlib::Absolutepath] $path = undef,

  Boolean $use_default_config_files_hash = true,
  Hash $config_files_hash                = {},

  Optional[String] $bolt_yaml_template      = 'psick/bolt/project/bolt.yaml.epp',
  Optional[String] $inventory_yaml_template = undef,
  Hash $options_hash                        = {},

  Optional[String] $data_repo_url = undef,

  Boolean $control_repo_integrate = false,
  Stdlib::Url $control_repo_url = 'https://github.com/example42/psick',

) {

  $bolt_dir = pick($path, psick::get_user_home($user))

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

  $default_config_hash = {
    [ "${bolt_dir}/modules" , "${bolt_dir}/site-modules" ] => {
      ensure => tp::ensure2dir($ensure)
    },
    "${bolt_dir}/bolt.yaml" => {
      content => psick::template($bolt_yaml_template),
    },
    "${bolt_dir}/inventory.yaml" => {
      content => psick::template($inventory_yaml_template),
    },
  }

  if $data_repo_url {
    $data_dir_config_hash = { }
  } else {
    if $use_default_config_files_hash {
      $data_dir_config_hash = {
        "${bolt_dir}/data" => {
          ensure => tp::ensure2dir($ensure)
        }
      }
    } else {
      $data_dir_config_hash = { }
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

  if $control_repo_integrate {
    tp::dir { $bolt_dir:
      source  => $control_repo_url,
      vcsrepo => 'git',
    }
  } else {
    file { $bolt_dir:
      ensure => tp::ensure2dir($ensure)
    }
  }

  if $data_repo_url {
    tp::dir { "${bolt_dir}/data":
      source  => $data_repo_url,
      vcsrepo => 'git',
    }
  }

}
