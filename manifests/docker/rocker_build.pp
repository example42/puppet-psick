# @define psick::docker::rocker_build
#
# Build images using esiting Puppet code
#
define psick::docker::rocker_build (

  String[1]                              $ensure              = 'present',

  Variant[Undef,Hash]                    $puppet_facts        = undef,
  Variant[Undef,String]                  $puppet_manifest     = undef,
  Variant[Undef,String]                  $puppet_arguments    = undef,
  String                                 $puppet_script       = '/etc/puppetlabs/code/environments/production/bin/papply.sh',

  Variant[Undef,String]                  $template            = 'psick/docker/Rockerfile.erb',
  String[1]                              $workdir             = '/var/tmp',

  String                                 $username            = '',

  String                                 $image_name          = '',
  String[1]                              $image_os            = downcase($::operatingsystem),
  String[1]                              $image_osversion     = $::operatingsystemmajrelease,

  Variant[Undef,String]                  $maintainer          = undef,
  String                                 $from                = '',
  Variant[Undef,String]                  $repository          = $title,
  Variant[Undef,String]                  $repository_tag      = 'latest',
  Array                                  $prepend_lines       = [],
  Array                                  $append_lines        = [],

  Variant[Undef,String]                  $copy                = '',
  Any                                    $cmd                 = undef,
  Any                                    $expose              = undef,
  String                                 $env                 =
  'PATH=/opt/puppetlabs/puppet/bin:/usr/bin:/bin:/sbin:/usr/sbin:$PATH',
  String                                 $mount               = '/opt/puppetlabs /etc/puppetlabs /root/.gem',
  String                                 $label               = 'com.puppet.dockerfile="/Dockerfile"',

  Variant[Undef,Array]                   $exec_environment    = undef,
  Variant[Boolean,Pattern[/on_failure/]] $exec_logoutput      = 'on_failure',

  Boolean                                $always_build        = true,
  String                                 $build_options       = '',

  ) {

  include ::psick::docker

  $puppet_settings = tp_lookup('puppet-agent','settings','tinydata','merge')
  $image_codename = $puppet_settings['apt_release']

  $real_from = $from ? {
    ''      => "${image_os}:${image_osversion}",
    default => $from,
  }
  $real_copy = $copy ? {
    ''       => 'puppet_env /etc/puppetlabs/code/environments/production',
    default  => $copy,
  }
  $username_prefix = $username ? {
    ''      => $::psick::docker::username ? {
      ''      => '',
      default => "${::psick::docker::username}/",
    },
    default => "${username}/",
  }
  $basedir_path =
  "${workdir}/${username_prefix}${image_os}_${image_osversion}/${title}"
  $real_image_name = $image_name ? {
    ''      => "${username_prefix}${repository}:${repository_tag}",
    default => $image_name,
  }
  file { [ "${basedir_path}/Rockerfile" , "${basedir_path}/root/Dockerfile" ]:
    ensure  => $ensure,
    content => template($template),
    require => Exec["mkdir -p ${basedir_path}/root"],
  }

  Exec {
    path    => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin',
    timeout => 3000,
  }

  exec { "mkdir -p ${basedir_path}/root":
    creates => "${basedir_path}/root",
  }
  $exec_refreshonly = $always_build ? {
    true  => false,
    false => true,
  }
  $exec_require = $::psick::docker::install_class ? {
    ''      => undef,
    default => Class[$::psick::docker::install_class],
  }
  exec { "bash -c rocker build ${title}":
    command     => "rocker build ${build_options}",
    cwd         => $basedir_path,
    subscribe   => File["${basedir_path}/Rockerfile"],
    environment => $exec_environment,
    logoutput   => $exec_logoutput,
    refreshonly => $exec_refreshonly,
    require     => $exec_require,
  }

}
