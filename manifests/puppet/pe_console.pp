# This class manages tp::test for PE Console
#
class psick::puppet::pe_console (
  Boolean $manage                  = $::psick::manage,
  Boolean $noop_manage             = $::psick::noop_manage,
  Boolean $noop_value              = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    Tp::Test {
      cli_enable => true,
      template   => '',
    }

    $nginx_settings = {
      package_name => 'pe-nginx',
      service_name => 'pe-nginx',
    }
    tp::test { 'nginx': settings_hash => $nginx_settings }

    if versioncmp($::aio_agent_version, '6') < 0 {
      $activemq_settings = {
        package_name => 'pe-activemq',
        service_name => 'pe-activemq',
        log_dir_path => '/var/log/puppetlabs/activemq',
        log_file_path => '/var/log/puppetlabs/activemq/activemq.log',
      }
      tp::test { 'activemq': settings_hash => $activemq_settings }
    }
  }
}
