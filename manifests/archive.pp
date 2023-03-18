# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   psick::archive { 'namevar': }
define psick::archive (
  Psick::Ensure                                $ensure = 'present',
  Enum['download','extract','compress','auto'] $action = 'auto',

  Optional[String]               $source = $title,
  Optional[Stdlib::Absolutepath] $download_dir = '/var/tmp',
  Optional[String]               $download_command = undef,
  Integer                        $download_timeout = 600,
  Array                          $download_exec_env = [],

  Optional[String]               $extract_dir = undef,
  Optional[String]               $extract_created_dir = undef,
  Optional[String]               $extract_command = undef,
  Integer                        $extract_timeout = 600,
  Array                          $extract_exec_env = [],

  Optional[String]               $compress_dir = undef,
  Optional[String]               $compress_command = undef,
  Optional[String]               $compress_output_file = undef,
  Integer                        $compress_timeout = 600,
  Array                          $compress_exec_env = [],

) {
  if $source {
    $source_filename = parse_url($source,'filename')
    $source_filetype = parse_url($source,'filetype')
    $source_dirname = parse_url($source,'filedir')
  }
  $download_command_default=lookup('psick::archive::download_command', Hash, deep, {})
  $extract_command_default=lookup('psick::archive::extract_command', Hash, deep, {})
  $compress_command_default=lookup('psick::archive::compress_command', Hash, deep, {})

  $real_download_command = $download_command ? {
    undef   => $download_command_default['command'],
    default => $download_command,
  }

  $real_extract_command = $extract_command ? {
    undef      => $source_filetype ? {
      '.tgz'     => $extract_command_default['tgz'],
      '.gz'      => $extract_command_default['gz'],
      '.bz2'     => $extract_command_default['bz2'],
      '.tar'     => $extract_command_default['tar'],
      '.zip'     => $extract_command_default['zip'],
      default    => $extract_command_default['tgz'],
    },
    default => $extract_command,
  }

  $real_compress_command = $compress_command ? {
    undef      => $source_filetype ? {
      '.tgz'     => $compress_command_default['tgz'],
      '.gz'      => $compress_command_default['gz'],
      '.bz2'     => $compress_command_default['bz2'],
      '.tar'     => $compress_command_default['tar'],
      '.zip'     => $compress_command_default['zip'],
      default    => $compress_command_default['tgz'],
    },
    default => $compress_command,
  }

  $real_extract_created_dir = $extract_created_dir ? {
    undef   => $source_filename,
    default => $extract_created_dir,
  }

  if $action == 'download' or $action == 'auto' {
    if $source {
      exec { "Download ${source} in ${download_dir}":
        cwd         => $download_dir,
        command     => "${real_download_command} ${download_command_default['pre_args']} ${source} ${download_command_default['post_args']}", # lint:ignore:140chars
        creates     => "${download_dir}/${source_filename}",
        timeout     => $download_timeout,
        path        => $facts['path'],
        environment => $download_exec_env,
      }
    }
  }

  if $action == 'extract' or $action == 'auto' {
    if $source {
      exec { "Extract ${source} in ${extract_dir}":
        cwd         => $extract_dir,
        command     => "${real_extract_command} ${source}",
        creates     => "${extract_dir}/${real_extract_created_dir}",
        timeout     => $extract_timeout,
        path        => $facts['path'],
        environment => $extract_exec_env,
      }
    }
  }

  if $action == 'compress' or $action == 'auto' {
    if $compress_output_file {
      exec { "Compress ${compress_dir} in ${compress_output_file}":
        command     => "${real_compress_command} ${compress_output_file} ${compress_dir}",
        creates     => $compress_output_file,
        timeout     => $compress_timeout,
        path        => $facts['path'],
        environment => $compress_exec_env,
      }
    } else {
      notify { 'psick::archive compress failure':
        message => 'You must specifiy a valid path for $compress_output_file when using the compress action in psick::archive' # lint:ignore:140chars
      }
    }
  }
}
