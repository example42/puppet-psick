# @summary Set an external fact via a file resource
# This define creates an external fact as a file, so the fact value
# is not immediately available in the Puppet run when the
# fact is applied. (to have external facts immediately available
# place them in the facts directory of a module.
#
define psick::puppet::set_external_fact (
  Any $value,
  Enum['absent','present'] $ensure = 'present',
) {

  $external_facts_dir = $::kernel ? {
    'Windows' => 'C:\ProgramData\PuppetLabs\facter\facts.d',
    default   => '/etc/puppetlabs/facter/facts.d',
  }

  if !defined(Psick::Tools::Create_dir[$external_facts_dir]) {
    psick::tools::create_dir { $external_facts_dir:
      before => File["${external_facts_dir}/${title}.yaml"],
    }
  }

  file { "${external_facts_dir}/${title}.yaml":
    ensure  => $ensure,
    content => "---\n  ${title}: ${value}\n",
  }

}
