# Define psick::services::systemd_script
#
# This define manages the creation of a systemd script and of
# the relevant service.
#
define psick::services::systemd_script (
  Enum['present','absent'] $ensure = present,
  Optional[String] $source = undef,
  Optional[String] $content = undef,
  Optional[String] $template = undef,
  Optional[String] $epp = undef,
  Optional[String] $path = "/usr/local/sbin/${title}",
  Optional[String] $service_ensure = undef,
  Variant[Undef,Boolean,String] $service_enable = undef,
  String $systemd_template = 'psick/services/systemd.erb',
  Optional[String] $systemd_after    = 'network.target',
  Optional[String] $systemd_before   = undef,
){
  $manage_content = tp_content($content, $template, $epp)
  file { $path:
    ensure  => $ensure,
    content => $manage_content,
    source  => $source,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  }
  file { "/etc/systemd/system/${title}.service":
    ensure  => $ensure,
    content => template($systemd_template),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }
  if ($service_ensure or $service_enable)
  and $ensure == 'present' {
    service { $title:
      ensure    => $service_ensure,
      enable    => $service_enable,
      subscribe => [ File["/etc/systemd/system/${title}.service"],File[$path] ],
    }
  }
}
