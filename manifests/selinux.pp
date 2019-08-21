# This class manages selinux basic configuration
#
# @param manage If to actually manage any resource in this profile or not#
# @param selinux_file_template The path of the template (with erb or epp suffix)
#                           to use for the content of /etc/selinux/config.
#                           If empty or selinux is missing the file is not managed.
# @param state The value of the SELINUX parameter in /etc/selinux/config
# @param type  The value of the SELINUXTYPE parameter in /etc/selinux/config
# @param selinux_dir_source The source of the contents of /etc/selinux dir
#                           (format: puppet:///modules/...)
#                           If empty or selinux is missing the dir is not managed.
# @param selinux_dir_recurse The recurse param of the /etc/selinux dir resource
# @param selinux_dir_force   The force param of the /etc/selinux dir resource
# @param selinux_dir_purge   The purge param of the /etc/selinux dir resource
# @param no_noop Set noop metaparameter to false to all the resources of this class.
#
class psick::selinux (
  Boolean $manage                    = $::psick::manage,
  Enum['enforcing','permissive','disabled'] $state       = 'enforcing',
  Enum['targeted','minimum','mls','default','src'] $type = 'targeted',
  Enum['0','1'] $setlocaldefs        = '0',
  String $selinux_file_template      = 'psick/selinux/selinux.epp',
  String $selinux_dir_source         = '',
  Boolean $selinux_dir_recurse       = true,
  Boolean $selinux_dir_force         = true,
  Boolean $selinux_dir_purge         = false,
  Boolean         $no_noop           = false,
) {
  if $manage {
    if !$::psick::noop_mode and $no_noop {
      info('Forced no-noop mode in psick::icinga2')
      noop(false)
    }
    $selinux_params = {
      state         => $state,
      type          => $type,
      setlocaldefs  => $setlocaldefs,
    }
    if getvar('selinux') == true {
      $setenforce_notify = Exec['psick_selinux_setenforce']
    } else {
      $setenforce_notify = undef
    }
    if getvar('selinux')!= undef and $selinux_file_template != '' {
      file { '/etc/selinux/config':
        ensure  => present,
        content => psick::template($selinux_file_template,$selinux_params),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => $setenforce_notify,
      }
    }
    if getvar('selinux') != undef and $selinux_dir_source != '' {
      file { '/etc/selinux':
        ensure  => directory,
        source  => $selinux_dir_source,
        recurse => $selinux_dir_recurse,
        force   => $selinux_dir_force,
        purge   => $selinux_dir_purge,
        owner   => 'root',
        group   => 'root',
        notify  => $setenforce_notify,
      }
    }

    $setenforce_status = $state ? {
      'permissive' => '0',
      'disabled'   => '0',
      'enforcing'  => '1',
    }

    exec { 'psick_selinux_setenforce':
      command     => "setenforce ${setenforce_status}",
      path        => $::path,
      refreshonly => true,
    }

    # Relabeling required when switching from disabled to permissive or enforcing.
    if $state in ['enforcing','permissive'] and $facts['selinux'] == false {
      file { '/.autorelabel':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        content => "# Created by Puppet for disabled to ${state} SELinux switch\n",
      }
    }
    if $state in ['disabled'] and $facts['selinux'] == true {
      notify { 'Reboot needed':
        message => 'You need to reboot the system to fully disable SElinux. Now operating in permissive mode',
      }
    }
  }
}
