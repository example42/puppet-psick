# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include psick::puppet::facter
class psick::puppet::facter (
  Psick::Ensure $ensure        = 'present',
  Boolean $manage              = $psick::manage,
  Boolean $noop_manage         = $psick::noop_manage,
  Boolean $noop_value          = $psick::noop_value,
  String $config_file_dir      = '/etc/puppetlabs/facter',
  String $config_file_template = 'psick/puppet/facter/facter.conf.epp',
  Hash $cli_settings           = {},
  Hash $global_settings        = {},
  Hash $fact_groups            = {},
  Array[String] $blocklist     = [],
  Array[Hash] $ttls            = [],
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }
    $parameters = {
      cli_settings    => $cli_settings,
      global_settings => $global_settings,
      fact_groups     => $fact_groups,
      blocklist       => $blocklist,
      ttls            => $ttls,
    }
    if $cli_settings != {}
    or $global_settings != {}
    or $fact_groups != {}
    or $blocklist != []
    or $ttls != [] {
      psick::tools::create_dir { "psick::puppet::facter ${config_file_dir}":
        path   => $config_file_dir,
        before => File["${config_file_dir}/facter.conf"],
      }
      file { "${config_file_dir}/facter.conf":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => psick::template($config_file_template,$parameters),
      }
    }
  }
}
