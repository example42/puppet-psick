# Installs java version given by title using upstream tarballs
# It works only for Linux and supports:
# - Different vendors ($vendor)
#   - 'openjdk' : Installs Openjdk
#   - 'oracle'  : Installs Oracle JDK
# - Different versions ($version)
#
# The `title` have to be one of `openjdk-java-{7..9}` or `oracle-java-{6..9}`
#
# @param ensure
#   ensure the package is `present` or `absent`.
# @param vendor
#   What vendor to use for JDK tarballs
# @param user
#   user owning java installation
# @param group
#   group owning java installation
# @param set_alternatives
#   set /etc/alternatives for this java installation (dafaults to true)
# @param bin_alternatives
#   links to set from /etc/alternatives to the java bin dir
# @param lib_alternatives
#   links to set from /etc/alternatives to the java lib dir
# @param tarball_source
#   optional param to override source of java tarball
# @param tarball_path
#   optional param to override path of java tarball
# @param tarball_extract_path
#   optional param to override extract path of java tarball
# @param tarball_creates
#   optional param to override creates of java tarball
# @param version
#   optional exact version of the java installation (e.g. '11.0.2')
#   defaults to latest version noted in common.yaml
#
define psick::java::install_tarball (
  Enum['present','absent'] $ensure                         = 'present',
  Optional[String] $version                                = undef,
  Variant[Undef,Stdlib::HTTPSUrl,Stdlib::HTTPUrl] $base_source_url = undef,
  Stdlib::Absolutepath $java_install_dir                   = '/opt/java-versions',
  Stdlib::Absolutepath $java_download_dir                  = '/opt/java-versions',
  Enum['openjdk','oracle'] $vendor                         = 'openjdk',
  String $user                                             = 'root',
  String $group                                            = 'root',
  Boolean $create_symlink                                  = true,
  Boolean $set_alternatives                                = true,
  Array $bin_alternatives = ['java','jjs','keytool','pack200','rmid','rmiregistry','unpack200'],
  Array $lib_alternatives = ['jexec'],
  Optional[String] $tarball_source                        = undef,
  Optional[String] $tarball_path         = undef,
  Optional[String] $tarball_extract_path = undef,
  Optional[String] $tarball_creates      = undef,

) {

  $java_array_version = split(pick($version,$title),'[.]')
  $java_major_version = $java_array_version[0]

  $dir_ensure = $ensure ? {
    'absent'  => 'absent',
    'present' => 'directory',
  }

  $link_ensure = $ensure ? {
    'absent'  => 'absent',
    'present' => 'link',
  }

#  $jdk_defaults = lookup('jdk_defaults',Hash,'first',{})
  $jdk_defaults = {
    'oracle' => {
      '6' => '',
      '7' => '',
      '8' => '',
      '9' => '',
      '10' => '',
      '11' => '11.0.1',
      '12' => '',
    },
    'openjdk' => {
      '6' => '',
      '7' => '',
      '8' => '8.0.4',
      '9' => '9.0.4',
      '10' => '',
      '11' => '11.0.1',
      '12' => '',
    },
  }

  $vendor_base_source_url = $vendor ? {
    'oracle'  => 'https://download.java.net/oracle/',
    'openjdk' => 'https://download.java.net/openjdk/'
  }

  if ! defined(File[$java_install_dir]) {
    file { $java_install_dir:
      ensure => directory,
    }
  }

  if ! defined(File[$java_download_dir]) {
    file { $java_download_dir:
      ensure => directory,
    }
  }

  case $vendor {
    'openjdk': {
      $tar_version = pick($version,$jdk_defaults[$vendor][$java_major_version])
      $tar_dir = "jdk-${tar_version}"
      $tar_source = "${vendor_base_source_url}/openjdk/openjdk-${tar_version}_linux-x64_bin.tar.gz"
      $tar_path = "${java_download_dir}/openjdk-${tar_version}_linux-x64_bin.tar.gz"
      $tar_extract_path = $java_install_dir
      $tar_creates = "${tar_extract_path}/${tar_dir}"
      $alternatives_prio = 1100 + $java_major_version
    }
    'oracle': {
      case $java_major_version {
        /7|8|9/:  {
          $tar_version = pick($version,$jdk_defaults[$vendor][$java_major_version])
          $tar_dir = "jdk${tar_version}"
          $tar_source = "${vendor_base_source_url}/oracle/java/jdk/jdk-${tar_version[2]}u${tar_version[6,-1]}-linux-x64.tar.gz"
          $tar_path = "${java_download_dir}/jdk-${tar_version[2]}u${tar_version[6,-1]}-linux-x64.tar.gz"
          $tar_extract_path = $java_install_dir
          $tar_creates = "${tar_extract_path}/${tar_dir}"
          $alternatives_prio = 1100 + $java_major_version
        }
        /^11/:  {
          $tar_version = pick($version,$jdk_defaults[$vendor][$java_major_version])
          $tar_dir = "jdk-${tar_version}"
          $tar_source = "${vendor_base_source_url}/bnotk-generic/oracle/java/jdk/jdk-${tar_version}_linux-x64_bin.tar.gz"
          $tar_path = "${java_download_dir}/jdk-${tar_version}_linux-x64_bin.tar.gz"
          $tar_extract_path = $java_install_dir
          $tar_creates = "${tar_extract_path}/${tar_dir}"
          $alternatives_prio = 1100 + $java_major_version
        }
        default: {
          fail("No valid JDK version provided with ${vendor} ${java_major_version}")
        }
      }
    }
    default: {
      fail("No valid JDK version provided with ${vendor} ${java_major_version}")
    }
  }
  $real_extract_path = pick($tarball_extract_path, $tar_extract_path)
  $real_creates = pick($tarball_creates, $tar_creates)
  $java_home = "${real_extract_path}/${tar_dir}"

  if !defined( File[$real_extract_path] ) {
    file { $real_extract_path:
      before => Archive["java-install-${title}"],
    }
  }
  archive { "java-install-${title}":
    proxy_server => lookup('proxy_url',Optional[Hash],'first',undef),
    path         => pick($tarball_path,$tar_path),
    source       => pick($tarball_source, $tar_source),
    extract      => true,
    extract_path => $real_extract_path,
    creates      => $real_creates,
    user         => $user,
    group        => $group,
  }
  if $set_alternatives {
    $bin_alternatives.each | $a | {
      alternative_entry { "${real_creates}/bin/${a}":
        ensure   => present,
        altlink  => "/usr/bin/${a}",
        altname  => $a,
        priority => $alternatives_prio,
        require  => Archive["java-install-${title}"],
      }
    }
    $lib_alternatives.each | $a | {
      alternative_entry { "${real_creates}/lib/${a}":
        ensure   => present,
        altlink  => "/usr/bin/${a}",
        altname  => $a,
        priority => $alternatives_prio,
        require  => Archive["java-install-${title}"],
      }
    }
  }

  if $create_symlink {
    file { "${java_install_dir}/${title}":
      ensure => link,
      target => $java_home,
    }
  }

}
