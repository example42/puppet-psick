# Generic repo management wrapper class
# Repos to create, besides default ones (when add_defaults = true)
# are looked up via hiera_hash
#
class psick::repo (
  Psick::Autoconf $auto_conf = $::psick::auto_conf,
  String $yum_resource       = 'yumrepo',     # Native resource type
  Hash $yum_repos            = {},
  String $apt_resource       = 'apt::source', # From puppetlabs-apt
  Hash $apt_repos            = {},
  String $zypper_resource    = 'zypprepo',    # From darin-zypprepo
  Hash $zypper_repos         = {},
) {

  # Default repos
  if $auto_conf {
    case $::osfamily {
      'RedHat': {
        tp::install { 'epel': auto_prerequisites => true }
      }
      'Debian': {
      }
      'Suse': {
      }
      default: {
      }
    }
  }

  if $yum_repos != {} {
    create_resources($yum_resource, $yum_repos)
  }
  if $apt_repos != {} {
    create_resources($apt_resource, $apt_repos)
  }
  if $yum_repos != {} {
    create_resources($zypper_resource, $yum_repos)
  }

}
