# Sample psick used by VMs in ostest Vagrant environment
# Used to code testing on different OS
#
class psick::ostest (

  Boolean $notify_enable = false,

) {

  if $notify_enable {
    notify { 'ostest role': }
  }
}
