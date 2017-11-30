# @summary Users management
# This psick manages basic user accounts providing parameter to manage the
# root user and other ones which accept hashes of resources to be passed to
# alternative defines used to create users. These hashes are looked up via
# a merge lookup with -- as knockout prefix.
#
# @param root_pw The root password. If set the root user resource is managed
#   here. Use root_params to customise other attributes of the user type for
#   root.
# @param root_params An hash of valid arguments of the user type. If this or
#   root_pw is set, the root user is managed by this class.
# @param users_hash An Hash passed to create resources based on the selected
#   module. The keys of this hash have to be compatible with the selected
#   module. The following extra keys can be used:
#     - ssh_authorized_keys: An array of keys to add to the users' authorized keys
#     - openssh_keygen: A boolean, if true a ssh key pair is automatically
#       generated for the user.
#     - sudo_template: The path as used by the template() fucntion of an erb
#         template to use to manage the user's sudo file. Nothing is created if
#         not defined.
# @param module A string to define which module to use to manage users:
#   'user' to use Puppet native type
#   'psick' to use the define psick::users::managed
#   'accounts' to use accounts::user from puppetlabs-accounts module
# @param delete_unmanaged If true all non system users not managed by Puppet
#    are automatically deleted.
class psick::users (
  Optional[String[1]] $root_pw  = undef,
  Hash $root_params             = {},
  Hash $users_hash              = {},
  Hash $available_users_hash    = {},
  Array $available_users_to_add = [],
  Enum['psick','accounts','user'] $module = 'psick',
  Boolean $delete_unmanaged     = false,
) {

  if $root_pw or $root_params != {}  {
    user { 'root':
      password => $root_pw,
      *        => $root_params,
    }
  }

  $added_users = $available_users_hash.filter | $username , $key | {
    $username in $available_users_to_add
  }
  $all_users = $added_users + $users_hash
  if $all_users != {} {
    $all_users.each |$u,$rv| {
      $v = delete($rv, ['ssh_authorized_keys','openssh_keygen','sudo_template'])
      # Find home
      if $v['home'] {
        $home_real = $v['home']
      } elsif $u == 'root' {
        $home_real = $::osfamily ? {
          'Solaris' => '/',
          default   => '/root',
        }
      } else {
        $home_real = $::osfamily ? {
          'Solaris' => "/export/home/${u}",
          default   => "/home/${u}",
        }
      }

      case $module {
        'psick': {
          psick::users::managed { $u:
            ensure           => $v['ensure'],
            comment          => $v['comment'],
            gid              => $v['gid'],
            groups           => $v['groups'],
            home             => $home_real,
            password         => $v['password'],
            password_max_age => $v['password_max_age'],
            password_min_age => $v['password_min_age'],
            shell            => $v['shell'],
            uid              => $v['uid'],
            *                => pick_default($v['extra_params'],{}),
          }
        }
        'accounts': {
          accounts::user { $u:
            ensure   => $v['ensure'],
            comment  => $v['comment'],
            gid      => $v['gid'],
            groups   => $v['groups'],
            home     => $v['home'],
            password => $v['password'],
            shell    => $v['shell'],
            uid      => $v['uid'],
            sshkeys  => $v['sshkeys'],
            *        => pick_default($v['extra_params'],{}),
          }
        }
        default: {
          user { $u:
            ensure           => $v['ensure'],
            comment          => $v['comment'],
            gid              => $v['gid'],
            groups           => $v['groups'],
            home             => $home_real,
            password         => $v['password'],
            password_max_age => $v['password_max_age'],
            password_min_age => $v['password_min_age'],
            shell            => $v['shell'],
            uid              => $v['uid'],
          }
        }
      }
      if has_key($rv,'ssh_authorized_keys') and $module != 'accounts' {
        $rv['ssh_authorized_keys'].each |$key| {
          $key_array   = split($key, ' ')
          ssh_authorized_key { "${u}_${key}":
            ensure => present,
            user   => $u,
            name   => $key_array[2],
            key    => $key_array[1],
            type   => $key_array[0],
            target => "${home_real}/.ssh/authorized_keys",
          }
        }
      }
      if has_key($rv,'openssh_keygen') {
        $rv['openssh_keygen'].each |$u,$vv| {
          psick::openssh::keygen { $u:
            * => $vv,
          }
        }
      }
      if has_key($rv,'sudo_template') {
        psick::sudo::directive { $u:
          template => $rv['sudo_template'],
        }
      }
    }
  }
  if $delete_unmanaged {
    resources { 'user':
      purge              => true,
      unless_system_user => true,
    }
  }
}
