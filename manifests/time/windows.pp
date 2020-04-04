# This psick manages ntp client on Windows
# Derived from https://github.com/ncorrare/windowstime
class psick::time::windows (
  Array $ntp_servers      = $::psick::time::servers,
  Array $fallback_servers = [],

  Boolean $manage      = $::psick::manage,
  Boolean $noop_manage = $::psick::noop_manage,
  Boolean $noop_value  = $::psick::noop_value,
) {
  if $manage {
    if $noop_manage {
      noop($noop_value)
    }

    $servers_ntp = inline_template('<% @ntp_servers.each do |s| -%><%= s %>,0x01 <% end -%>')
    $servers_fallback = inline_template('<% @fallback_servers.each do |s| -%><%= s %>,0x02 <% end -%>')
    $servers_registry = "${servers_ntp} ${servers_fallback}"
    $system32dir = $facts['os']['windows']['system32']

    registry_value { 'HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\Type':
      ensure => present,
      type   => string,
      data   => 'NTP',
    }
    registry_value { 'HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\NtpServer':
      ensure => present,
      type   => string,
      data   => $servers_registry,
      notify => Service['w32time'],
    }

    exec { 'c:/Windows/System32/w32tm.exe /resync':
      refreshonly => true,
    }

    service { 'w32time':
      ensure => running,
      enable => true,
      notify => Exec['c:/Windows/System32/w32tm.exe /resync'],
    }
  }
}
