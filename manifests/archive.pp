# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   psick::archive { 'namevar': }
define psick::archive (
  Psick::Ensure                                $ensure = 'present',
  Enum['download','extract','compress','auto'] $action = 'auto',

  Optional[String]              $source,
  Optional[Stdlib::Absoluepath] $download_dir = undef,
  Optional[String]              $download_command = undef,

  Optional[String]              $extract_dir = undef,
  Optional[String]              $extract_command = undef,

  Optional[String]              $compress_dir = undef,
  Optional[String]              $compress_command = undef,
  Optional[String]              $compress_output_file = undef,

) {

  if $source {
    $source_filename = parse_url($source,'filename')
    $source_filetype = parse_url($source,'filetype')
    $source_dirname = parse_url($source,'filedir')
  }
  $download_command_default=lookup('psick::archive::download_command', Hash, deep, {})
  $extract_command_default=lookup('psick::archive::extract_command', Hash, deep, {})
  $compress_command_default=lookup('psick::archive::compress_command', Hash, deep, {})

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

  if $action == 'download' or $action == 'auto' {
    if $source {
      exec { "Retrieve ${source} in ${work_dir} - ${title}":
        cwd         => $work_dir,
        command     => "${retrieve_command} ${retrieve_args} ${url}",
        creates     => "${work_dir}/${source_filename}",
        timeout     => $timeout,
        path        => $path,
        environment => $exec_env,
      }
    }
  }

}
