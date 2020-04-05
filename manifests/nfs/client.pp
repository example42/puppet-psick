# @summary Manage NFS client and mounts
#
# @param mounts_hash An hash of mountpoints to pass
#  to psick::nfs::mount define
#
# @example Client configuration with mount
#    psick::profiles::linux_classes:
#      nfs_client: psick::nfs::client
#
#    psick::nfs::client::mounts_hash:
#      data:
#        server: 10.42.42.101
#        share: /data
#        mountpoint: /mnt/data
class psick::nfs::client (
  Hash $mounts_hash    = {},
  Boolean $manage      = true,
  Boolean $noop_manage = false,
  Boolean $noop_value  = false,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    # Workaround for rcpbind service handling.
    tp::install { 'nfs-client':
      settings_hash => {
        service_enable => undef,
      }
    }

    $mounts_hash.each |$k,$v| {
      psick::nfs::mount { $k:
        * => $v,
      }
    }
  }
}
