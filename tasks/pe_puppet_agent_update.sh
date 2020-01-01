#!/usr/bin/env bash
if [[ -n "${PT_puppet_server}" ]]; then
  puppet_server=$PT_puppet_server
else
  puppet_server=$(grep "^server_list"  /etc/puppetlabs/puppet/puppet.conf | cut -d '=' -f 2 | cut -d ':' -f 1 | sed -e 's/^[ \t]*//')
fi

if [[ "x${puppet_server}" == "x" ]]; then
  puppet_server=$(/opt/puppetlabs/puppet/bin/puppet config print server)
fi
echo "## Fetching install script from ${puppet_server}"

/opt/puppetlabs/puppet/bin/curl --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem "https://${puppet_server}:8140/packages/current/install.bash" | bash
