# @summary This class manages /etc/hosts using Puppetdb data
#
# @example
#   include psick::hosts::puppetdb
class psick::hosts::puppetdb (
  String          $ensure              = 'present',
  Boolean         $manage              = $::psick::manage,
  String          $template            = 'psick/hosts/puppetdb/hosts.epp',
  Hash $puppetdb_hosts_override_hash       = {},
  String $puppetdb_fact_address            = 'networking.ip',
  String $puppetdb_fact_address6           = 'networking.ip6',
  String $puppetdb_fact_name               = 'networking.hostname',
  String $puppetdb_fact_alias              = 'networking.fqdn',
  String $localhost   = "127.0.0.1\tlocalhost\tlocalhost.localdomain",
  String $puppethost  = "${::serverip}\tpuppet\t${::servername}",
  Array $extra_hosts            = [],
  Boolean         $no_noop             = false,
  StdLib::Absolutepath $path           = '/etc/hosts',

) {

  if $manage {
    if !$::psick::noop_mode and $no_noop {
      info('Forced no-noop mode in psick::icinga2')
      noop(false)
    }

    # PuppetDB query (TODO: Optimize inventory query)
    $hosts_query = 'nodes { deactivated is null }'
    $hosts_result = puppetdb_query($hosts_query)
    $hosts_puppetdb_array = $hosts_result.map |$node| {
      $k = $node['certname']
      $hosts_facts_query = "inventory[facts] { trusted.certname = '${k}' }"
      $hosts_facts = puppetdb_query($hosts_facts_query)
      $host_ip4 = getvar("hosts_facts.0.facts.${puppetdb_fact_address}")
      $host_ip6 = getvar("hosts_facts.0.facts.${puppetdb_fact_address6}")
      $host_name = getvar("hosts_facts.0.facts.${puppetdb_fact_name}")
      $host_alias = getvar("hosts_facts.0.facts.${puppetdb_fact_alias}")
      if $host_ip4 {
        $result_ip4 = "${host_ip4}\t${host_name}\t${host_alias}\n"
      } else {
        $result_ip4 = undef
      }
      if $host_ip6 {
        $result = "${result_ip4}${host_ip6}\t${host_name}\t${host_alias}"
      } else {
        $result = $result_ip4
      }
    }
    $sorted_hosts_puppetdb_array = sort(delete_undef_values($hosts_puppetdb_array))
    $hosts_final_array = [ $localhost ] + [ $puppethost ] + $extra_hosts + $sorted_hosts_puppetdb_array
    $content = psick::template($template,{ hosts_final_array => $hosts_final_array })
    file { $path:
      ensure  => $ensure,
      content => $content,
    }

  } # END if $manage    

}
