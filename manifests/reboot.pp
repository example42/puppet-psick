# This profile triggers a system reboot
#
# This profiles uses puppetfile/reboot module to manage
# system reboots.
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
) {

  $message = "Rebooting: when ${when} - apply ${apply} - timeout ${timeout}"

  if $manage {
    reboot { $reboot_name:
      apply   => $apply,
      message => $message,
      when    => $when,
      timeout => $timeout,
    }
  }
}
