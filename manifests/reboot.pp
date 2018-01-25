# This profile triggers a system reboot using puppetlabs-reboot
# module.
#
# 
# @example Enable firstrun mode and set reboot class on windows
#   and linux
#   firstrun_enable: true
#   psick::firstrun::linux::reboot_class: psick::reboot
#   psick::firstrun::windows::reboot_class: psick::reboot
#
class psick::reboot (
  Boolean $manage                       = true,
  Enum['immediately','finished'] $apply = 'finished',
  Enum['refreshed','pending'] $when     = 'pending',
  String $reboot_name                   = 'Psick Reboot',
  Integer $timeout                      = 60,
  Optional[String] $schedule_name       = undef,
  Boolean $subscribe_anchor             = false,
) {

  $message = "Rebooting: when ${when} - apply ${apply} - timeout ${timeout}"

  if $schedule_name {
    include psick::schedule
  }

  if $manage {
    reboot { $reboot_name:
      apply    => $apply,
      message  => $message,
      when     => $when,
      timeout  => $timeout,
      schedule => $schedule_name,
    }
  }
  if $subscribe_anchor {
    anchor { 'reboot':
      notify   => Reboot[$reboot_name],
      schedule => $schedule_name,
    }
  }
}
