# @summary Set an external fact via a file resource
# This define creates an external fact as a file, so the fact value
# is not immediately available in the Puppet run when the
# fact is applied. (to have external facts immediately available
# place them in the facts directory of a module.
#
define psick::puppet::set_external_fact (
  Enum['absent','present'] $ensure = 'present',
  Optional[Any] $value             = undef,
  Optional[String] $template       = undef,
  String $mode                     = '0644',
  Hash $options                    = {},
) {

  if ! $value and ! $template {
    fail('You must specify either a value or a template to use')
  }

  $external_facts_dir = $::kernel ? {
    'Windows' => 'C:\ProgramData\PuppetLabs\facter\facts.d',
    default   => '/etc/puppetlabs/facter/facts.d',
  }
  $file_content = $value ? {
    undef   => template($template),
    default => "---\n  ${title}: ${value}\n",
  }
  $file_path = $value ? {
    undef   => "${external_facts_dir}/${title}",
    default => "${external_facts_dir}/${title}.yaml",
  }

  if !defined(Psick::Tools::Create_dir[$external_facts_dir]) {
    psick::tools::create_dir { $external_facts_dir:
      before => File[$file_path],
    }
  }

  file { $file_path:
    ensure  => $ensure,
    content => $file_content,
    mode    => $mode,
  }

}
