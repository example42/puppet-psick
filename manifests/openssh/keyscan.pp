# Define: psick::openssh::keyscan
# Scans an host key and add it to known_hosts fileof the defined
# user
#
define psick::openssh::keyscan (
  String                         $user             = 'root',
  String                         $host             = $title,
  Optional[Stdlib::AbsolutePath] $known_hosts_path = undef,
) {

  $known_hosts_path_real = $known_hosts_path ? {
    undef   => $user ? {
      'root'  => '/root/.ssh/known_hosts',
      default => "/home/${user}/.ssh/known_hosts",
    },
    default => $known_hosts_path,
  }

  $known_hosts_dir = dirname($known_hosts_path_real)

  exec { "ssh-keyscan-${title}":
    command => "ssh-keyscan ${host} >> ${known_hosts_path_real}",
    user    => $user,
    unless  => "grep ${host} ${known_hosts_path_real}",
    require => Psick::Tools::Create_dir[$known_hosts_dir],
  }

  psick::tools::create_dir { $known_hosts_dir:
    owner => $user,
  }
}

