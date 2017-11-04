#
class psick::nfs::client () {

  # Workaround for rcpbind service handling.
  tp::install { 'nfs-client':
    settings_hash => {
      service_enable => undef,
    }
  }

}
