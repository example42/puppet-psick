#
define psick::nodejs::npm (
  String $user,
  String $package_name      = $title,
  Optional[String] $nvm_dir = undef,
  Optional[String] $version = undef,
  String $npm_params        = '-g',
  String $nvm_env           = 'default',
) {
  if $nvm_dir == undef {
    $final_nvm_dir = $user ? {
      'root'  => '/root',
      default => "/home/${user}",
    }
  }
  else {
    $final_nvm_dir = $nvm_dir
  }

  $full_package_name = $version ? {
    undef   => $package_name,
    default => "${package_name}@${version}",
  }
  exec { "npm install ${full_package_name}":
    cwd         => $final_nvm_dir,
    command     => ". ${final_nvm_dir}/.nvm/nvm.sh && nvm exec ${nvm_env} npm install ${full_package_name} ${npm_params}",
    user        => $user,
    environment => ["NVM_DIR=${final_nvm_dir}/.nvm"],
    unless      => ". ${final_nvm_dir}/.nvm/nvm.sh && nvm exec ${nvm_env} npm ls ${full_package_name} -g",
    provider    => shell,
  }
}
