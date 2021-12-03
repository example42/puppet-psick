#
define psick::nodejs::install (
  String $user,
  Optional[String] $nvm_dir = undef,
  String $version      = $title,
  Boolean $set_default = false,
  Boolean $from_source = false,
) {

  if $nvm_dir == undef {
    $final_nvm_dir = $user ? {
      'root'  => '/root/.nvm',
      default => "/home/${user}/.nvm"
    }
  }
  else {
    $final_nvm_dir = $nvm_dir
  }

  if $from_source {
    $nvm_install_options = ' -s '
  }
  else {
    $nvm_install_options = ''
  }

  exec { "nvm install node version ${version}":
    cwd         => $final_nvm_dir,
    command     => ". ${final_nvm_dir}/nvm.sh && nvm install ${nvm_install_options} ${version}",
    user        => $user,
    unless      => ". ${final_nvm_dir}/nvm.sh && nvm which ${version}",
    environment => [ "NVM_DIR=${final_nvm_dir}" ],
    provider    => shell,
  }

  if $set_default {
    exec { "nvm set node version ${version} as default":
      cwd         => $final_nvm_dir,
      command     => ". ${final_nvm_dir}/nvm.sh && nvm alias default ${version}",
      user        => $user,
      environment => [ "NVM_DIR=${final_nvm_dir}" ],
      unless      => ". ${final_nvm_dir}/nvm.sh && nvm which default | grep ${version}",
      provider    => shell,
      require     => Exec["nvm install node version ${version}"],
    }
  }
}
