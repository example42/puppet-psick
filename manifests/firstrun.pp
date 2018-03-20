# @summary Special class applied only at first Puppet run
#
# This special class is supposed to be included ONLY at the first Puppet run.
# It's up to user to decide if to enable it (by setting psick::enable_firstrun)
# and it's up to the user to decide what classes to include in this run and
# if to trigger a system reboot after this Puppet run.
#
# By default, if psick::enable_firstrun is set to true, this class automatically
# includes the classes listed in the ${::kernel}_classes hashes, triggers a reboot
# (on Windows) and creates an external fact that prevents a reboot
# cycle.
# IMPORTANT NOTE: If firstrun mode is activated on an existing infrastructure
# or if the 'firstrun' external fact is removed from nodes, this class will
# included in the main psick class as if this were a real first Puppet run.
# This will trigger a, probably unwanted, reboot on Windows nodes (and in any
# other node for which reboot is configured.
# Set psick::firstrun::${kernel}_reboot to false to prevent undesired reboots.
#
# Use cases:
# - Set a desired hostname on Windows, reboot and join an AD domain
# - Install aws-sdk gem, reboot and have ec2_tags facts since the first real Puppet run
# - Set external facts with configurable content (not via pluginsync) and
#   run a catalog only when they are loaded (after the first Puppet run)
# - Any case where a configuration or some installations have to be done
#   in a separated and never repeating first Puppet run. With or without a
#   system reboot
#
# @example Enable firstrun and configure it to set hostname on Windows and reboot
#     psick::enable_firstrun: true
#     psick::firstrun::windows_classes:
#       hostname: psick::hostname
#     psick::firstrun::windows_reboot: true # (Default value)
#
# @example Enable firstrun and configure it to set hostname and proxy
# on Linux but do not trigger any reboot
#     psick::enable_firstrun: true
#     psick::firstrun::linux_classes:
#       hostname: psick::hostname
#       proxy: psick::proxy
#     psick::firstrun::linux_reboot: false # (Default value)
# For each of these $::kernel_classes parameters, it's expected an Hash of key-values:
# Keys can have any name, and are used as markers to allow overrides,
# exceptions management and customisations across Hiera's hierarchies.
# Values are actual class names to include in the node's catalog only at
# first Puppet execution.
# They can be classes from psick module or any other module.
#
# @example Disable the whole class (no resource from this class is declared)
#     psick::firstrun::manage: false
#
# @param manage If to actually manage any resource. Set to false to disable
#   any effect of this psick::firstrun class.
#
# @param linux_classes Hash with the list of classes to include
#   in the first Puppet run when $::kernel is Linux. Of each key-value
#   of the hash, the key is used as marker to eventually override
#   across Hiera hierarchies and the value is the name of the class
#   to actually include. Any key name can be used, but the value
#   must be a valid class existing the the $modulepath. If the value
#   is set to empty string ('') then the class of the relevant marker
#   is not included.
#
# @param windows_classes Hash with the list of classes to include
#   in the first Puppet run when $::kernel is windows.
#
# @param solaris_classes Hash with the list of classes to include
#   in the first Puppet run when $::kernel is Solaris.
#
# @param darwin_classes Hash with the list of classes to include
#   in the first Puppet run when $::kernel is Darwin.
#
# @param reboot_apply The apply parameter to pass to reboot type
# @param reboot_when The when parameter to pass to reboot type
# @param reboot_message The message parameter to pass to reboot type
# @param reboot_name The name of the reboot type
# @param reboot_timeout The timeout parameter to pass to reboot type
#
class psick::firstrun (

  Boolean $manage = $::psick::manage,

  Psick::Class $linux_classes   = {},
  Psick::Class $windows_classes = {},
  Psick::Class $darwin_classes  = {},
  Psick::Class $solaris_classes = {},

  Boolean $linux_reboot   = false,
  Boolean $windows_reboot = true,
  Boolean $darwin_reboot  = false,
  Boolean $solaris_reboot = false,

  Enum['immediately','finished'] $reboot_apply = 'finished',
  Enum['refreshed','pending']    $reboot_when  = 'refreshed',
  String $reboot_message  = 'firstboot mode enabled, rebooting after first Puppet run',
  String $reboot_name     = 'Rebooting',
  Integer $reboot_timeout = 60,
) {

  if $manage {
    if !empty($linux_classes) and $::kernel == 'Linux' {
      $linux_classes.each |$n,$c| {
        if $c != '' {
          contain $c
          Class[$c] -> Psick::Puppet::Set_external_fact['firstrun']
        }
      }
    }
    if !empty($windows_classes) and $::kernel == 'windows' {
      $windows_classes.each |$n,$c| {
        if $c != '' {
          contain $c
          Class[$c] -> Psick::Puppet::Set_external_fact['firstrun']
        }
      }
    }
    if !empty($darwin_classes) and $::kernel == 'Darwin' {
      $darwin_classes.each |$n,$c| {
        if $c != '' {
          contain $c
          Class[$c] -> Psick::Puppet::Set_external_fact['firstrun']
        }
      }
    }
    if !empty($solaris_classes) and $::kernel == 'Solaris' {
      $solaris_classes.each |$n,$c| {
        if $c != '' {
          contain $c
          Class[$c] -> Psick::Puppet::Set_external_fact['firstrun']
        }
      }
    }

    # Reboot
    $kernel_down = downcase($::kernel)
    $reboot = getvar("${kernel_down}_reboot")
    $fact_notify = $reboot ? {
      false => undef,
      true  => Reboot[$reboot_name],
    }

    psick::puppet::set_external_fact { 'firstrun':
      value  => 'done',
      notify => $fact_notify,
    }

    if $reboot {
      reboot { $reboot_name:
        apply   => $reboot_apply,
        message => $reboot_message,
        when    => $reboot_when,
        timeout => $reboot_timeout,
      }
    }

  }
}
