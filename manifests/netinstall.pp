# Define: psick::netinstall
#
# This defines simplifies the installation of a file
# downloaded from the web. It provides arguments to manage
# different kind of downloads and custom commands.
#
# == Variables
#
# [*url*]
#   The Url of the file to retrieve. Required.
#   Example: http://www.example42.com/file.tar.gz
#
# [*destination_dir*]
#   The final destination where to unpack or copy what has been
#   downloaded. Required.
#   Example: /var/www/html
#
# [*retrieve_args*]
#   A string of arguments to pass to wget.
#
# [*extracted_dir*]
#   The name of a directory or file created after the extraction
#   Needed only if its name is different from the downloaded file name
#   (without suffixes). Optional.
#
# [*owner*]
#   The user owner of the directory / file created. Default: root
#
# [*group*]
#   The group owner of the directory / file created. Default: root
#
# [*timeout*]
#   The timeout in seconds for each command executed
#
# [*work_dir*]
#   A temporary work dir where file is downloaded. Default: /var/tmp
#
# [*path*]
#  Define the path for the exec commands.
#  Default: /bin:/sbin:/usr/bin:/usr/sbin
#
# [*exec_env*]
#   Define any additional environment variables to be used with the
#   exec commands. Note that if you use this to set PATH, it will
#   override the path attribute. Multiple environment variables
#   should be specified as an array.
#
# [*extract_command*]
#   The command used to extract the downloaded file.
#   By default is autocalculated according to the file extension
#   Set 'rsync' if the file has to be placed in the destination_dir
#   as is (for example for war files)
#
# [*preextract_command*]
#   An optional custom command to run before extracting the file.
#
# [*postextract_command*]
#   An optional custom command to run after having extracted the file.
#
define psick::netinstall (
  String $url,
  Stdlib::Absolutepath $destination_dir,
  Optional[String] $extracted_dir = undef,
  String $retrieve_command    = 'wget',
  String $retrieve_args       = '', # lint:ignore:params_empty_string_assignment
  String $owner               = 'root',
  String $group               = 'root',
  Stdlib::Filemode $timeout   = '3600',
  Stdlib::Absolutepath $work_dir = '/var/tmp',
  String $path                = '/bin:/sbin:/usr/bin:/usr/sbin',
  Variant[String,Boolean] $extract_command     = '', # lint:ignore:params_empty_string_assignment
  Variant[String,Boolean] $preextract_command  = '', # lint:ignore:params_empty_string_assignment
  Variant[String,Boolean] $postextract_command = '', # lint:ignore:params_empty_string_assignment
  Optional[Stdlib::Absolutepath] $postextract_cwd = undef,
  Array $exec_env             = [],
  Optional[Stdlib::Absolutepath] $creates = undef,
) {
  $source_filename = parse_url($url,'filename')
  $source_filetype = parse_url($url,'filetype')
  $source_dirname = parse_url($url,'filedir')

  $real_extract_command = $extract_command ? {
    ''      => $source_filetype ? {
      '.tgz'     => 'tar -zxf',
      '.gz'      => 'tar -zxf',
      '.bz2'     => 'tar -jxf',
      '.tar'     => 'tar -xf',
      '.zip'     => 'unzip',
      default    => 'tar -zxf',
    },
    default => $extract_command,
  }

  $extract_command_second_arg = $real_extract_command ? {
    /^cp.*/    => '.',
    /^rsync.*/ => '.',
    default    => '',
  }

  $real_extracted_dir = $extracted_dir ? {
    undef   => $real_extract_command ? {
      /(^cp.*|^rsync.*)/         => $source_filename,
      /(^tar -zxf*|^tar -jxf*)/  => regsubst($source_dirname,'.tar',''),
      default                    => $source_dirname,
    },
    default => $extracted_dir,
  }

  $real_postextract_cwd = $postextract_cwd ? {
    undef   => "${destination_dir}/${real_extracted_dir}",
    default => $postextract_cwd,
  }

  $real_creates = $creates ? {
    undef   => "${destination_dir}/${real_extracted_dir}",
    default => $creates,
  }

  if $preextract_command and $preextract_command != '' {
    exec { "PreExtract ${source_filename} in ${destination_dir} - ${title}":
      command     => $preextract_command,
      subscribe   => Exec["Retrieve ${url} in ${work_dir} - ${title}"],
      refreshonly => true,
      path        => $path,
      environment => $exec_env,
      timeout     => $timeout,
    }
  }

  exec { "Retrieve ${url} in ${work_dir} - ${title}":
    cwd         => $work_dir,
    command     => "${retrieve_command} ${retrieve_args} ${url}",
    creates     => "${work_dir}/${source_filename}",
    timeout     => $timeout,
    path        => $path,
    environment => $exec_env,
  }

  if $real_extract_command and $real_extract_command != '' {
    exec { "Extract ${source_filename} from ${work_dir} - ${title}":
      command     => "mkdir -p ${destination_dir} && cd ${destination_dir} && ${real_extract_command} ${work_dir}/${source_filename} ${extract_command_second_arg}", # lint:ignore:140chars
      unless      => "ls ${destination_dir}/${real_extracted_dir}",
      creates     => $real_creates,
      timeout     => $timeout,
      require     => Exec["Retrieve ${url} in ${work_dir} - ${title}"],
      path        => $path,
      environment => $exec_env,
      notify      => Exec["Chown ${source_filename} in ${destination_dir} - ${title}"],
    }

    exec { "Chown ${source_filename} in ${destination_dir} - ${title}":
      command     => "chown -R ${owner}:${group} ${destination_dir}/${real_extracted_dir}",
      refreshonly => true,
      timeout     => $timeout,
      require     => Exec["Extract ${source_filename} from ${work_dir} - ${title}"],
      path        => $path,
      environment => $exec_env,
    }
  }

  if $postextract_command and $postextract_command != '' {
    exec { "PostExtract ${source_filename} in ${destination_dir} - ${title}":
      command     => $postextract_command,
      cwd         => $real_postextract_cwd,
      subscribe   => Exec["Extract ${source_filename} from ${work_dir} - ${title}"],
      refreshonly => true,
      timeout     => $timeout,
      require     => [Exec["Retrieve ${url} in ${work_dir} - ${title}"],Exec["Chown ${source_filename} in ${destination_dir} - ${title}"]],
      path        => $path,
      environment => $exec_env,
    }
  }
}
