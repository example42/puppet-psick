# This class installs Varant using the unibet/vagrant module
#
# @param version The Vagrant version to install
# @param plugins An array of Vagrant plugins to install
# @param default_plugins An array of Vagrant plugins installed by default
# @param The user to use for plugins installation
#
class psick::vagrant (
  Variant[Undef,String] $version = undef,
  Array $plugins         = [] ,
  Array $default_plugins = [ 'vagrant-hostmanager' , 'vagrant-vbguest' ,  'vagrant-cachier', 'vagrant-triggers' , 'vagrant-  pe_build'],
  String $user           = 'root',
) {

  class { '::vagrant':
    version => $version,
  }

  $all_plugins = $default_plugins + $plugins

  $all_plugins.each | $plugin | {
    ::vagrant::plugin { $plugin:
      user => $user,
    }
  }

}
