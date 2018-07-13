# @summary Manage Jenkins plugins
#
define psick::jenkins::plugin (
  String $version               = 'latest',
  String $jenkins_dir           = '/var/lib/jenkins',
  String $jenkins_url           = 'http://updates.jenkins-ci.org',
  Optional[String] $install_script_source   = undef,
  Optional[String] $install_script_template = 'psick/jenkins/install_jenkins_plugin.sh.epp',
  Boolean $enable               = true,
  String $jenkins_user          = 'jenkins',
  String $jenkins_group         = 'jenkins',
  String $jenkins_service       = 'jenkins',
  Variant[Integer,String] $exec_timeout = '1200',
) {

  include ::psick::unzip
  $plugins_dir = "${jenkins_dir}/plugins"
  $plugin_name = "${name}@${version}"

  if (!defined(File[$plugins_dir])) {
    file { [ $plugins_dir ]:
      ensure => directory,
      owner  => $jenkins_user,
      group  => $jenkins_group,
    }
  }
  if (!defined(File["${jenkins_dir}/install_jenkins_plugin.sh"])) {
    $install_script_content = pick_default(psick::template($install_script_template),undef)
    file { "${jenkins_dir}/install_jenkins_plugin.sh":
      ensure  => present,
      owner   => $jenkins_user,
      group   => $jenkins_group,
      mode    => '0750',
      source  => $install_script_source,
      content => $install_script_content,
    }
  }

  # Allow plugins that are already installed to be enabled/disabled.
  if $enable == false {
    file { [ "${plugins_dir}/${name}.hpi.disabled", "${plugins_dir}/${name}.jpi.disabled" ]:
      ensure => present,
      owner  => $jenkins_user,
      notify => Service[$jenkins_service],
    }
  }

  exec { "install_jenkins_plugins-${name}" :
    command => "./install_jenkins_plugin.sh -a -d ${plugins_dir} -u ${jenkins_url} ${plugin_name}",
    cwd     => $jenkins_dir,
    require => [ File["${jenkins_dir}/install_jenkins_plugin.sh"], Class['psick::unzip'] ],
    path    => [ '/usr/bin', '/usr/sbin', '/bin' , $jenkins_dir],
    user    => $jenkins_user,
    unless  => "test -d ${plugins_dir}/${name}",
    notify  => Service[$jenkins_service],
    timeout => $exec_timeout,
  }
}
