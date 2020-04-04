# Generic class to manage sudo
#
# @param sudoers_template The erb template to use for /etc/sudoers If empty the
#                         file is not managed
# @param admins The array of the users to add to the admin group
# @param sudoers_d_source The source (as used in source => ) to use to populate
#                         the /etc/sudoers.d directory
# @param purge_sudoers_dir If to purge all the files existing on the local node
#                          and not present in sudoers_d_source
# @param directives An hash of sudo directives to pass to psick::sudo::directive
#                   Note this is not a real class parameter but a key looked up
#                   with lookup('psick::sudo::directives', {})
#
class psick::sudo (
  String                   $sudoers_template  = '',
  Array                    $admins            = [ ],
  Variant[String[1],Undef] $sudoers_d_source  = undef,
  String                   $sudoers_owner     = 'root',
  String                   $sudoers_group     = 'root',
  Boolean                  $purge_sudoers_dir = false,

  Boolean                  $manage            = $::psick::manage,
  Boolean                  $noop_manage       = $::psick::noop_manage,
  Boolean                  $noop_value        = $::psick::noop_value,
) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $sudoers_template != '' {
      file { '/etc/sudoers':
        ensure  => file,
        mode    => '0440',
        owner   => $sudoers_owner,
        group   => $sudoers_group,
        content => template($sudoers_template),
        notify  => Exec['sudo_syntax_check'],
      }
      file { '/etc/sudoers.broken':
        ensure => absent,
        before => Exec['sudo_syntax_check'],
      }
      exec { 'sudo_syntax_check':
        command     => 'visudo -c -f /etc/sudoers && ( cp -f /etc/sudoers /etc/sudoers.lastgood ) || ( mv -f /etc/sudoers /etc/sudoers.broken ; cp /etc/sudoers.lastgood /etc/sudoers ; exit 1) ', # lint:ignore:140chars
        refreshonly => true,
      }
    }

    file { '/etc/sudoers.d':
      ensure  => directory,
      mode    => '0440',
      owner   => $sudoers_owner,
      group   => $sudoers_group,
      source  => $sudoers_d_source,
      recurse => true,
      purge   => $purge_sudoers_dir,
    }

    $directives = lookup('psick::sudo::directives', Hash, 'deep', {})
    $directives.each |$name,$opts| {
      ::psick::sudo::directive { $name:
        * => $opts,
      }
    }

    if $::virtual == 'virtualbox' and $purge_sudoers_dir {
      psick::sudo::directive { 'vagrant':
        source => 'puppet:///modules/psick/sudo/vagrant',
        order  => 30,
      }
    }
  }
}
