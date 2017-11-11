## First run mode

First run mode is a special condition, which can be applied at the first Puppet run
on the clients, where a seleceted number of classes are included and configured.
Optionally, a reboot may be triggered at the end of this first Puppet run.

The next Puppet runs will be normal and will use the normal configurations expected
in each nodes.

Possible use cases for Firstrun mode:
 - Set a desired hostname on Windows, reboot and join an AD domain
 - Install aws-sdk gem, reboot and have ec2_tags facts since the first real Puppet run
 - Set external facts with configurable content (not via pluginsync) and run a catalog
   only when they are loaded (after the first Puppet run)
 - Any case where a configuration or some installations have to be done
   in a separated and never repeating first Puppet run. With or without a
   system reboot.

To enable first run mode (by default it's disabled) set:

    psick::enable_firstrun: true

To define which classes to include in nodes, according to each $::kernel:

    psick::firstrun::windows_classes:
      hostname: psick::hostname
    psick::firstrun::windows_reboot: true # (Default value)

    psick::firstrun::linux_classes:
      hostname: psick::hostname
      proxy: psick::proxy
    psick::firstrun::linux_reboot: false # (Default value)

IMPORTANT NOTE: If firstrun mode is activated on an existing infrastructure or if
the 'firstrun' external fact is removed from nodes, this class will be included
in the main psick class as if this were a real first Puppet run.
This will trigger a, probably unwanted, reboot on Windows nodes (and in any
 other node for which reboot is configured.

Set psick::firstrun::${kernel}_reboot to false to prevent undesired reboots.

