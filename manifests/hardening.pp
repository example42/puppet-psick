# This class manages the general hardening of a system. It just provides, as
# params, the names of the classes to include in order to manage specific
# hardening activities.
#
# @example Define all the available hardening classes. Set a class name to an
#          empty string to avoid to include it
#   psick::hardening::pam_class: '::psick::hardening::pam'
#   psick::hardening::packages_class: '::psick::hardening::packages'
#   psick::hardening::services_class: '::psick::hardening::services'
#   psick::hardening::tcpwrappers_class: '::psick::hardening::tcpwrappers'
#   psick::hardening::suid_class: '::psick::hardening::suid_sgid'
#   psick::hardening::users_class: '::psick::hardening::users_sgid'
#   psick::hardening::securetty_class: '::psick::hardening::securetty'
#   psick::hardening::network_class: '::psick::hardening::network'
#
# @param pam_class Name of the class to include to manage PAM
# @param packages_class Name of the class where are defined packages to remove
# @param services_class Name of the class to include re defined services to stop
# @param securetty_class Name of the class where /etc/securetty is managed
# @param tcpwrappers_class Name of the class to include to manage TCP wrappers
# @param suid_class Name of the class to include to remove SUID but from execs
# @param users_class Name of the class to manage users
# @param network_class Name of the class where some network hardening is done
# @param manage If to actually manage any resource in this class. If false no
#               resource is managed. Default value is taken from main psick class.
# @param noop_manage If to use the noop() function for all the resources provided
#                    by this class. If this is true the noop function is called
#                    with $noop_value argument. This overrides any other noop setting
#                    (either set on client's puppet.conf or by noop() function in
#                    main psick class). Default from psick class.
# @param noop_value The value to pass to noop() function if noop_manage is true.
#                   It applies to all the resources (and classes) declared in this class
#                   If true: noop metaparamenter is set to true, resources are not applied
#                   If false: noop metaparameter is set to false, and any eventual noop
#                   setting is overridden: resources are always applied.
#                   Default from psick class.
class psick::hardening (

  String $pam_class         = '',
  String $packages_class    = '',
  String $services_class    = '',
  String $tcpwrappers_class = '',
  String $suid_class        = '',
  String $users_class       = '',
  String $securetty_class   = '',
  String $network_class     = '',

  Boolean $manage           = $::psick::manage,
  Boolean $noop_manage      = $::psick::noop_manage,
  Boolean $noop_value       = $::psick::noop_value,

) {

  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    if $pam_class != '' {
      contain $pam_class
    }

    if $packages_class != '' {
      contain $packages_class
    }

    if $services_class != '' {
      contain $services_class
    }

    if $tcpwrappers_class != '' {
      contain $tcpwrappers_class
    }

    if $suid_class != '' {
      contain $suid_class
    }

    if $users_class != '' {
      contain $users_class
    }

    if $securetty_class != '' {
      contain $securetty_class
    }

    if $network_class != '' {
      contain $network_class
    }

  }
}
