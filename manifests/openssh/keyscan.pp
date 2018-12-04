# Define: psick::openssh::keyscan
# Scans an host key and add it to known_hosts fileof the defined
# user
# [*user*]
#   Set the user for which to add the hsot key to ~/.ssh/known_hosts. Default is taken from
#   the title.
# [*host*]
#   The hostname of the remote host to scan
# [*known_hosts_path*]
#   The absolute path where to write the remote host ssh key. Overrides default  ~/.ssh/known_hosts
#
# [*create_ssh_dir*]
#   If to create the .ssh directory in the user's home
define psick::openssh::keyscan (
  String                         $user             = 'root',
  String                         $host             = $title,
  Optional[Stdlib::AbsolutePath] $known_hosts_path = undef,
  Boolean                        $create_ssh_dir   = false,
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
  }

  if $create_ssh_dir {
    psick::tools::create_dir { "openssh_keyscan_${known_hosts_dir}":
      path   => $known_hosts_dir,
      owner  => $user,
      before => Exec["ssh-keyscan-${title}"],
    }
  }
}

