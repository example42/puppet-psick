# @class psick::jenkins::scm_sync
# @summary Installs and configures SCM Sync plugin
# 
class psick::jenkins::scm_sync (

  Variant[Boolean,String]    $ensure     = 'present',

  String $config_template = 'psick/jenkins/scm_sync/scm-sync-configuration.xml.erb',

  Optional[String] $repository_url = $::psick::jenkins::scm_sync_repository_url,

) {

  if !defined(Psick::Jenkins::Plugin['scm-sync-configuration']) {
    psick::jenkins::plugin { 'scm-sync-configuration':
      exec_timeout => 120,
    }
  }
  if $config_template != '' and $repository_url {
    file { "${::psick::jenkins::home_dir}/scm-sync-configuration.xml" :
      ensure  => $ensure,
      mode    => '0644',
      owner   => 'jenkins',
      group   => 'jenkins',
      notify  => Service['jenkins'],
      replace => false,
      content => template($config_template),
      require => Package['jenkins'],
    }
  }

  if $repository_url {
    # Trigger scm sync
    exec { 'trigger_jenkins_scm_sync' :
      command => "sleep 5 ; curl http://127.0.0.1:8080/plugin/scm-sync-configuration/reloadAllFilesFromScm -u admin:\$(cat 'secrets/initialAdminPassword')",
      cwd     => $::psick::jenkins::home_dir,
      creates => "${::psick::jenkins::home_dir}/scm-sync-configuration.success.log",
      require => [ File["${::psick::jenkins::home_dir}/scm-sync-configuration.xml"], Service['jenkins'] ],
      user    => 'jenkins',
      notify  => Exec['jenkins_reload'],
    }
    exec { 'jenkins_reload' :
      command     => 'service jenkins restart',
      # command     => "curl -X POST http://127.0.0.1:8080/reload -u admin:\$(cat 'secrets/initialAdminPassword')",
      cwd         => $::psick::jenkins::home_dir,
      require     => [ File["${::psick::jenkins::home_dir}/scm-sync-configuration.xml"], Service['jenkins'] ],
      # user        => 'jenkins',
      refreshonly => true,
    }
  }
}
