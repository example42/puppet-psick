# Class psick::lvm
# 
# Creates a default lv
class psick::lvm (
  String $ensure  = 'installed',

  Boolean $create_default_vg = false,
  String $default_vg_name    = 'vg00',
  String $default_lv_name    = 'data',
  Hash $default_lv_options   = {},
  String $default_fs_type    = 'xfs',
  Boolean $default_createfs  = false,
  Boolean $install_package   = true,
) {

  if $install_package  {
    package { 'lvm2':
      ensure => $ensure,
    }
  }

  $all_disks = keys($facts['disks'])
  $available_disks = delete($all_disks, $all_disks[0])
  $real_pvs =  $available_disks.map|$k| { "/dev/${k}" }

  if $available_disks != [] and $create_default_vg {
    lvm::volume_group { $default_vg_name:
      physical_volumes => $real_pvs,
    }
    lvm::logical_volume { $default_lv_name:
      volume_group => $default_vg_name,
      createfs     => $default_createfs,
      fs_type      => $default_fs_type,
      *            => $default_lv_options,
    }
  }
}
