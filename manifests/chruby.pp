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
# @param no_noop Set noop metaparameter to false to all the resources of this class.
#   This overrides any noop setting which might be in place.
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
  Boolean         $no_noop          = false,

) {

  # We declare resources only if $manage = true
  if $manage {
    
    # If no_noop is set it's enforced, unless psick::noop_mode is 
    if ! $::psick::noop_mode and $no_noop {
      info('Forced no-noop mode in psick::chruby')
      noop(false)
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
