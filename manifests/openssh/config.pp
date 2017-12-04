# = Define: psick::openssh::config
#
# This define configures a user ~/.ssh/config file
#
# == Parameters
#
# [*content*]
#   Sets the value of content parameter for the ~/.ssh/config file.
#   Can be set as an array (joined with newlines)
#
# [*source*]
#   Sets the value of source parameter for the ~/.ssh/config file
#
# [*template*]
#   Sets the value of content parameter for the ~/.ssh/config file
#   Note: This option is alternative to the source one
#
# [*ensure*]
#   Define if the ~/.ssh/config file should be present (default) or 'absent'
#
# [*user*]
#   Set the user for which to create a ~/.ssh/config file. Default is taken from
#   the title.
#
# [*path*]
#   Set the path of the openssh config file (this overrides any path derived from
#   user parameter
#
# [*options_hash*]
#   Custom hash of options to use in templates.
#
# [*create_ssh_dir*]
#   If to create the .ssh directory containing SSH config file
#
define psick::openssh::config (
  Enum['present','absent'] $ensure         = present,
  Variant[Undef,String]    $content        = undef,
  Variant[Undef,String]    $template       = 'psick/generic/spaced_with_stanzas.erb',
  Variant[Undef,String]    $source         = undef,
  Optional[String]         $user           = undef,
  Optional[String]         $path           = undef,
  Hash                     $options_hash   = {},
  Boolean                  $create_ssh_dir = false,
) {

  $user_real = $user ? {
    undef    => $title,
    default => $user,
  }

  # $parameters is used in the default generic template
  $parameters = $options_hash

  # Define the final content: if $content is set a line break is added at the
  # end, if not, the $template is used, if set.
  $real_content = $content ? {
    undef     => $template ? {
      undef   => undef,
      default => template($template),
    },
    default   => inline_template('<%= [@content].flatten.join("\n") + "\n" %>'),
  }

  $base_dir = $path ? {
    undef   => $user_real ? {
      'root'  => "/${user_real}/.ssh",
      default => "/home/${user_real}/.ssh",
    },
    default => dirname($path),
  }

  $path_real = $path ? {
    undef   => "${base_dir}/config",
    default => $path,
  }

  file { $path_real:
    ensure  => $ensure,
    owner   => $user_real,
    group   => $user_real,
    mode    => '0640',
    content => $real_content,
    source  => $source,
  }

  if $create_ssh_dir {
    psick::tools::create_dir { $base_dir:
      owner  => $user_real,
      group  => $user_real,
      before => File[$path_real],
    }
  }
}
