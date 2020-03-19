## psick::mounts - Manages system mount points

This class manages mount points on the system, handling the relevant entries in /etc/fstab

It uses Puppet's native mount define to manage mount point, which allows management of single lines
of /etc/fstab leaving the existing entries as is

To configure a list of mount points simply include psick::mounts (this has no effect of any kind by default) and
then configure via Hieradata as follows:

    psick::mounts::mounts:
      '/':
        ensure: 'mounted'
        device: '/dev/md/2'
        fstype: 'ext4'
        options: 'defaults'
      '/mnt/nfs':
        ensure: 'mounted'
        device: 'nfshost:/path/to/nfs/share"
        fstype: 'nfs"
        options: 'defaults'
        atboot:  true

The parameters of the mounts are the ones of the mount resource type (write "puppet describe mount" for full docs).
The has of mount points is looked up via a normal Hiera lookup, without merge across the hierarchies.


