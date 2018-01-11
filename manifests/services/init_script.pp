# Define psick::services::init_script
#
# This define manages the creation of a script under /etc/init.d and of
# the relevant service.
#
define psick::services::init_script (
  Enum['present','absent'] $ensure = present,
  Optional[String] $source = undef,
  Optional[String] $content = undef,
  Optional[String] $template = undef,
  Optional[String] $epp = undef,
  Optional[String] $service_ensure = undef,
  Variant[Undef,Boolean,String] $service_enable = undef,
){
  $manage_content = tp_content($content, $template, $epp)
  file { "/etc/init.d/${title}":
    ensure  => $ensure,
    content => $manage_content,
    source  => $source,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
  }
  if ($service_ensure or $service_enable)
  and $ensure == 'present' {
    service { $title:
      ensure    => $service_ensure,
      enable    => $service_enable,
      subscribe => File["/etc/init.d/${title}"],
    }
  }
}
