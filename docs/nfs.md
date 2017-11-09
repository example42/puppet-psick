## How to manage NFS with PSICK

PSICK classes and profiles related to nfs:

  - Class ```psick::nfs::server``` installs NFS server and manages exports
  - Class ```psick::nfs::client``` installs NFS client and manages mounts
  - Define ```psick::nfs::export``` manages NFS exports on a server
  - Define ```psick::nfs::mounts``` manages NFS mounts on a client

## Configuration

Server configuration is as follows:

    psick::profiles::linux_classes:
      nfs_server: psick::nfs::server

    psick::nfs::server::exports_hash:
      data:
        share: /data
        guest: 10.42.42.0/16
        options: ro

Relevant client configuration looks like:

    psick::profiles::linux_classes:
      nfs_client: psick::nfs::client

    psick::nfs::client::mounts_hash:
      data:
        server: 10.42.42.101
        share: /data
        mountpoint: /mnt/data

