#!/usr/bin/env bash
if [[ -n "${PT_puppet_server}" ]]; then
  puppet_server=$PT_puppet_server
else
  puppet_server=$(/opt/puppetlabs/puppet/bin/puppet config print server)
fi
/opt/puppetlabs/puppet/bin/curl -k --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem "https://${puppet_server}:8140/packages/current/install.bash" | bash

