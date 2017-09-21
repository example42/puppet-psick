# @summary Create a directory and its eventual parents
#
# @example Create the the directory /data/utils/bin
#    psick::tools::create_dir { '/data/utils/bin': }
#
# @param owner The owner of the created directory
# @param group The group of the created directory
# @param mode The mode of the created directory

define psick::tools::create_dir (
  Optional[String] $owner = undef,
  Optional[String] $group = undef,
  Optional[String] $mode = undef,
) {
  exec { "mkdir -p ${title}":
    path    => '/bin:/sbin:/usr/sbin:/usr/bin',
    creates => $title,
  }
  if $owner {
    exec { "chown ${owner} ${title}":
      path   => '/bin:/sbin:/usr/sbin:/usr/bin',
      onlyif => "[ $(ls -ld ${title} | awk '{ print \$3 }') != ${owner} ]",
    }
  }
  if $group {
    exec { "chgrp ${group} ${title}":
      path   => '/bin:/sbin:/usr/sbin:/usr/bin',
      onlyif => "[ $(ls -ld ${title} | awk '{ print \$4 }') != ${group} ]",
    }
  }
  if $mode {
    exec { "chmod ${mode} ${title}":
      path        => '/bin:/sbin:/usr/sbin:/usr/bin',
      subuscribe  => Exec["mkdir -p ${title}"],
      refreshonly => true,
    }
  }
}
