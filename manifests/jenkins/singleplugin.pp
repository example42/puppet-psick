# @summary Installs single Jenkins plugins
#   It doesn't manage dependencies
#
define psick::jenkins::singleplugin (
  String $version         = '',
  String $plugins_dir     = '/var/lib/jenkins/plugins',
  Boolean $enable         = true,
  String $jenkins_user    = 'jenkins',
  String $jenkins_group   = 'jenkins',
  String $jenkins_service = 'jenkins',
) {

  if $version != '' {
    $base_url = "http://updates.jenkins-ci.org/download/plugins/${name}/${version}"
  }
  else {
    $base_url = 'http://updates.jenkins-ci.org/latest'
  }

  if (!defined(File[$plugins_dir])) {
    file { [ $plugins_dir ]:
      ensure => directory,
      owner  => $jenkins_user,
      group  => $jenkins_group,
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

  exec { "download-jenkins-${name}" :
    command => "rm -f ${name}.hpi.disabled ${name}.jpi.disabled ; wget --no-check-certificate ${base_url}/${name}.hpi",
    cwd     => $plugins_dir,
    require => [ File[$plugins_dir] ],
    path    => [ '/usr/bin', '/usr/sbin', '/bin' ],
    user    => $jenkins_user,
    unless  => "test -f ${plugins_dir}/${name}.hpi || test -f ${plugins_dir}/${name}.jpi",
    notify  => Service[$jenkins_service],
  }
}
