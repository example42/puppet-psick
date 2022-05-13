# @summary Manages nfs server
#
# @param exports_hash Hash of export definitions to be passed
#   to psick::nfs::export
#
# @example Configure NFS server and export a directory:
#   psick::profiles::linux_classes:
#     nfs_server: psick::nfs::server
#   psick::nfs::server::exports_hash:
#     data:
#       share: /data
#       guest: 10.42.42.0/16
#
class psick::nfs::server (
  Hash $exports_hash   = {},
  Boolean $manage      = true,
  Boolean $noop_manage = false,
  Boolean $noop_value  = false,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    tp::install { 'nfs-server': }

    $exports_hash.each |$k,$v| {
      psick::nfs::export { $k:
        * => $v,
      }
    }
  }
}
