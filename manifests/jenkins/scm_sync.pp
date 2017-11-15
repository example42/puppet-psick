# @class psick::jenkins::scm_sync
# @summary Installs and configures SCM Sync plugin
# 
class psick::jenkins::scm_sync (

  Variant[Boolean,String]    $ensure     = 'present',

  String $config_template = 'psick/jenkins/scm_sync/scm-sync-configuration.xml.erb',

  String $repository_url  = $::psick::jenkins::scm_sync_repository_url,

) {

  if !defined(Psick::Jenkins::Plugin['scm-sync-configuration']) {
    psick::jenkins::plugin { 'scm-sync-configuration': }
  }
  if $config_template != '' {
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

}
