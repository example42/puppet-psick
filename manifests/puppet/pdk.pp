#
class psick::puppet::pdk (
  Psick::Ensure $ensure = 'present',
  #  String $dist,
  #  String $extract_command,
  Boolean         $auto_prereq              = $::psick::auto_prereq,
) {

  if $auto_prereq {
    include ::psick::ruby::buildgems
  }

  # Waiting for pdk repo
  #  package { 'pdk':
  #   ensure => $ensure,
  #}
  $dist = $facts['os']['family'] ? {
    'RedHat' => 'el',
    'SuSE'   => 'sles',
    'Debian' => 'ubuntu',
  }
  $arch = $facts['os']['family'] ? {
    'Debian' => 'amd64',
    default  => 'x86_64',
  }
  $url = "https://pm.puppetlabs.com/cgi-bin/pdk_download.cgi?dist=${dist}&rel=${facts['os']['release']['major']}&arch=${arch}&ver=latest"
  $command = $facts['os']['family'] ? {
    'RedHat' => "rpm -Uvh '${url}'",
    'SuSE'   => "rpm -Uvh '${url}'",
    'Debian' => "wget '${url}' -O pdk.deb && dpkg --install pdk.deb",
  }
  $unless_command = $facts['os']['family'] ? {
    'RedHat' => 'rpm -qi pdk',
    'SuSE'   => 'rpm -qi pdk',
    'Debian' => 'apt show pdk',
  }

  exec { 'Install PDK':
    command => $command,
    unless  => $unless_command,
  }
}
