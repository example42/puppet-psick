#!/usr/bin/env bash

server=$(puppet config print server)
/opt/puppetlabs/puppet/bin/curl --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem https://$server:8140/packages/current/install.bash | bash
