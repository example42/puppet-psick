# psick::chruby
#
# @summary This psick profile manages chruby.
#
# @example Include it to install chruby
#   include psick::chruby
#
# @example Include in PSICK via hiera (yaml)
#   psick::profiles::linux_classes:
#     chruby: psick::chruby
#
# @example Set no-noop mode and enforce changes even if noop is set for the agent
#     psick::chruby::no_noop: true
#
# @param manage If to actually manage any resource in this profile or not
# @param auto_prereq If to automatically install eventual dependencies.
#   Set to false if you have problems with duplicated resources, being sure that you
#   provide the needed prerequistes.
# @param noop_manage If to use the noop() function for all the resources provided
#                    by this class. If this is true the noop function is called
#                    with $noop_value argument. This overrides any other noop setting
#                    (either set on client's puppet.conf or by noop() function in
#                    main psick class). Default from psick class.
# @param noop_value The value to pass to noop() function if noop_manage is true.
#                   It applies to all the resources (and classes) declared in this class
#                   If true: noop metaparamenter is set to true, resources are not applied
#                   If false: noop metaparameter is set to false, and any eventual noop
#                   setting is overridden: resources are always applied.
#                   Default from psick class.
class psick::chruby (
  Psick::Ensure $ensure             = 'present',
  String $version                   = '0.3.7',
  String $default_ruby_version      = '2.4.3',
  StdLib::AbsolutePath $ruby_prefix = '/opt/rubies',
  String $user                      = 'puppet',
  Optional[String] $group           = undef,
  Optional[String] $sources_root    = undef,
  Optional[String] $download_root   = undef,

  Boolean         $manage           = $::psick::manage,
  Boolean         $auto_prereq      = $::psick::auto_prereq,
  Boolean         $noop_manage      = $::psick::noop_manage,
  Boolean         $noop_value       = $::psick::noop_value,

) {

  # We declare resources only if $manage = true
  if $manage {

    if $noop_manage {
      noop($noop_value)
    }

    $sources_dest = $sources_root ? {
      undef   => "${ruby_prefix}/sources",
      default => $sources_root
    }
    $download_dest = $download_root ? {
      undef   => "${ruby_prefix}/downloads",
      default => $download_root
    }
    psick::netinstall { "chruby-v${version}.tar.gz":
      destination_dir => $sources_dest,
      url             => "https://github.com/postmodern/chruby/archive/v${version}.tar.gz",
      extract_command => 'tar -zxf',
      owner           => $user,
      group           => $group,
      creates         => "${sources_dest}/chruby-${version}",
      before          => Exec['install chruby'],
    }

    exec { 'install chruby':
      cwd     => "${sources_dest}/chruby-${version}",
      command => 'make install',
      creates => '/usr/local/share/chruby',
      path    => [ '/sbin', '/usr/sbin', '/bin', '/usr/bin' ],
    }

    file { '/etc/profile.d/chruby.sh':
      ensure  => 'file',
      content => '. "/usr/local/share/chruby/chruby.sh"',
      require => Exec['install chruby'],
    }
  }
}
