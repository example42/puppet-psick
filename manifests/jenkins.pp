# @class psick::jenkins
# @summary Installs and configures Jenkins, also via SCM sync plugin
# This profile can be used to install and configure Jenkins using
# different modules.
#
# @param ensure If to install or remove jenkins (may not work on all
# select modules).
# @param module The module to use to install Jenkins. Default, 'psick',
# uses local psick classes.
# @param plugins An hash of Jenkins plugins to install.
# @param init_options An hash of options to use in init scripts.
# @param ssh_private_key_content The content of the ssh private key for the
# jenkins user. It's used to connect scm_sync_repository_url.
# @param ssh_public_key_content The content of the ssh public key for jenkins
#   user. If set, also the private one must be set, and
#   this public key has to be added on the GIT(hub/lab/...) web interface as
#   deploy key for the scm_sync_repository_url with write access.
# @param ssh_private_key_source The source of the ssh private key for the
#   jenkins user. It's used to connect scm_sync_repository_url.
#   This is alternative to ssh_private_key_content.
# @param ssh_public_key_source The source of the ssh public key for jenkins
#   user. This is alternative to ssh_public_key_content
# @param ssh_keys_generate If to automaticallty generate a ssh keypair for
#   the jenkins user to use to connect to scm_sync_repository_url or
#   any other remote node via ssh.
# @param scm_sync_repository_url The url of the git repo containing the Jenkins
#   configurations synced via the scm-sync plugin
# @param scm_sync_repository_host The hostname of the server which hosts the
#   scm_sync_repository_url. If set a ssh-keyscan is done and the host is added
#   to Jenkins's known_hosts file
# @param disable_setup_wizard If to (try) to disable the initial Jenkins
#   setup wizard. Set this to true and define a $admin_password to disable
#   it and set the admin password via Puppet
# @param basic_security_template The template to use for the groovy script that sets
#   the admin password.
#
# @example Install Jenkins and a pair of plugins
#    psick::base::linux_classes:
#      jenkins: psick::jenkins
#    psick::jenkins::plugins:
#      warnings:
#        enable: true
#      blueocean:
#        enable: true
#
# @example Install Jenkins, configure scm plugin with predefined keys, set admin
# password and disable initial Wizard
#    psick::base::linux_classes:
#      jenkins: psick::jenkins
#    psick::jenkins::scm_sync_repository_url: git@github.com:alvagante/jenkins.foss.psick.io-scmsync.git
#    psick::jenkins::scm_sync_repository_host: github.com
#    psick::jenkins::disable_setup_wizard: true
#    psick::jenkins::admin_password: 'example42'
#    psick::jenkins::ssh_private_key_source: puppet:///modules/profile/jenkins/id_rsa
#    psick::jenkins::ssh_public_key_source: puppet:///modules/profile/jenkins/id_rsa.pub
class psick::jenkins (

  Variant[Boolean,String] $ensure            = 'present',
  Enum['tp_profile'] $module                 = 'tp_profile',
  Hash $plugins                              = {},
  Hash $init_options                         = {},
  String $home_dir                           = '/var/lib/jenkins',

  Optional[String] $ssh_private_key_content  = undef,
  Optional[String] $ssh_public_key_content   = undef,
  Optional[String] $ssh_private_key_source   = undef,
  Optional[String] $ssh_public_key_source    = undef,

  Boolean $ssh_keys_generate                 = false,

  Optional[String] $scm_sync_repository_url  = undef,
  Optional[String] $scm_sync_repository_host = undef,

  Boolean $disable_setup_wizard              = false,
  String $basic_security_template            = 'psick/jenkins/basic-security.groovy.erb',
  String $admin_password                     = '',

  Boolean $manage                            = $::psick::manage,
  Boolean $noop_manage                       = $::psick::noop_manage,
  Boolean $noop_value                        = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $java_args_extra = $disable_setup_wizard ? {
      true  => '-Djenkins.install.runSetupWizard=false',
      false => '',
    }

    $default_init_options = {
      'NAME'           => 'jenkins',
      'JAVA'           => '/usr/bin/java',
      'JAVA_ARGS'      => "-Djava.awt.headless=true ${java_args_extra}",
      'PIDFILE'        => '/var/run/$NAME/$NAME.pid',
      'JENKINS_USER'   => '$NAME',
      'JENKINS_GROUP'  => '$NAME',
      'JENKINS_WAR'    => '/usr/share/$NAME/$NAME.war',
      'JENKINS_HOME'   => '/var/lib/$NAME',
      'RUN_STANDALONE' => 'true', # lint:ignore:quoted_booleans
      'JENKINS_LOG'    => '/var/log/$NAME/$NAME.log',
      'MAXOPENFILES'   => '8192',
      'HTTP_PORT'      => '8080',
      'PREFIX'         => '/$NAME',
      'JENKINS_ARGS'   => '--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT',
    }
    $all_init_options = $default_init_options + $init_options

    # Installation management
    case $module {
      'tp_profile': {
        contain ::psick::java
        contain ::tp_profile::jenkins
        $plugins.each |$k,$v| {
          psick::jenkins::plugin { $k:
            require => Package['jenkins'],
            *       => $v,
          }
        }
        tp::conf { 'jenkins::init':
          template     => 'psick/jenkins/init.erb',
          options_hash => $all_init_options,
          base_file    => 'init',
        }
        Tp::Conf['jenkins::init'] -> Psick::Jenkins::Plugin<| |>
      }
      default: {
        contain ::jenkins
      }
    }

    # SSH keys management
    if $ssh_keys_generate
    or $ssh_private_key_content
    or $ssh_public_key_content
    or $ssh_private_key_source
    or $ssh_public_key_source
    or $scm_sync_repository_host {
      psick::tools::create_dir { "jenkins_${home_dir}/.ssh":
        path    => "${home_dir}/.ssh",
        owner   => 'jenkins',
        group   => 'jenkins',
        mode    => '0700',
        require => Package['jenkins'],
        before  => Service['jenkins'],
      }
    }

    if $ssh_keys_generate {
      psick::openssh::keygen { 'jenkins':
        require => Psick::Tools::Create_dir["jenkins_${home_dir}/.ssh"],
        before  => Service['jenkins'],
        home    => $home_dir,
      }
    }

    if $ssh_private_key_content or $ssh_private_key_source {
      file { 'jenkins_id_rsa':
        ensure  => $ensure,
        path    => "${home_dir}/.ssh/id_rsa",
        mode    => '0600',
        owner   => 'jenkins',
        group   => 'jenkins',
        content => $ssh_private_key_content,
        source  => $ssh_private_key_source,
        before  => Service['jenkins'],
        require => Psick::Tools::Create_dir["jenkins_${home_dir}/.ssh"],
      }
    }

    if $ssh_public_key_content or $ssh_public_key_source {
      file { "${home_dir}/.ssh/id_rsa.pub" :
        ensure  => $ensure,
        mode    => '0644',
        owner   => 'jenkins',
        group   => 'jenkins',
        content => $ssh_public_key_content,
        source  => $ssh_public_key_source,
        before  => Service['jenkins'],
        require => Psick::Tools::Create_dir["jenkins_${home_dir}/.ssh"],
      }
    }

    if $scm_sync_repository_url {
      include ::psick::jenkins::scm_sync
    }

    # Pre-scan ssh host key of $scm_sync_repository_host and adds
    # them to known_hosts for to avoid ssh issues with unknown hosts keys
    if $scm_sync_repository_host {
      psick::openssh::keyscan { $scm_sync_repository_host:
        user             => 'jenkins',
        known_hosts_path => "${home_dir}/.ssh/known_hosts",
        require          => Package['jenkins'],
        before           => Service['jenkins'],
      }
    }

    # Extra step to disable setup Wizard
    if $admin_password != '' {
      file { "${home_dir}/init.groovy.d":
        ensure  => directory,
        owner   => 'jenkins',
        group   => 'jenkins',
        require => Package['jenkins'],
      }
      tp::conf { 'jenkins::basic-security.groovy':
        path    => "${home_dir}/init.groovy.d/basic-security.groovy",
        content => template($basic_security_template),
        mode    => '0640',
        owner   => 'jenkins',
        group   => 'jenkins',
        before  => Service['jenkins'],
      }
    }
  }
}
