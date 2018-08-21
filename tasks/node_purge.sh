#!/usr/bin/env bash

set -e

# verify whether we can rely on PE node classification. Use static list otherwise.
is_pe=$(/opt/puppetlabs/puppet/bin/facter -p pe_build)
if [ "$is_pe" = '' ]; then
  # manage your list of puppet infrastructure nodes here and remove the echo and exit line
  #
  pe_mom='master.domain.tld'
  pe_compiler='master.domain.tld compiler1.domain.tld compiler2.domain.tld'
  pe_puppetdb='puppetdb.domain.tld'
  pe_console='console.domain.tld'
  #
  echo 'FOSS Puppet required variables not set'
  exit 1

else

  # we need to find puppetdb from puppetdb.conf file
  # if file is missing we can exit
  if [ ! -e /etc/puppetlabs/puppet/puppetdb.conf ]; then
    echo "not running on a master... missing puppetdb.conf file. terminating"
    exit 1
  fi

  # get our certificate name
  certname=$(/opt/puppetlabs/puppet/bin/puppet agent --configprint certname)
  cacert="/etc/puppetlabs/puppet/ssl/certs/ca.pem"
  cert="/etc/puppetlabs/puppet/ssl/certs/$certname.pem"
  key="/etc/puppetlabs/puppet/ssl/private_keys/$certname.pem"

  # read puppetdb url from puppetdb.conf file
  server=$(grep server /etc/puppetlabs/puppet/puppetdb.conf | cut -d "=" -f2 |sed -e 's/^[ \t]*//')

  # get list of pe_compiler nodes classified with puppet_enterprise::profile::master class
  pe_compiler=$(/opt/puppetlabs/bin/puppet-query --urls $server --cacert $cacert --cert $cert --key $key 'resources[certname] { type = "Class" and title = "Puppet_enterprise::Profile::Master" }' | grep certname | cut -d '"' -f4)

  # pe master of masters node is classified with puppet_enterprise::profile::ochestrator
  pe_mom=$(/opt/puppetlabs/bin/puppet-query --urls $server --cacert $cacert --cert $cert --key $key 'resources[certname] { type = "Class" and title = "Puppet_enterprise::Profile::Orchestrator" }' | grep certname | cut -d '"' -f4)

  # puppetdb node is classified with puppet_enterprise::profile::puppetdb
  pe_puppetdb=$(/opt/puppetlabs/bin/puppet-query --urls $server --cacert $cacert --cert $cert --key $key 'resources[certname] { type = "Class" and title = "Puppet_enterprise::Profile::Puppetdb" }' | grep certname | cut -d '"' -f4)

  # pe-console node is classified with puppet_enterprise::profile::console
  pe_console=$(/opt/puppetlabs/bin/puppet-query --urls $server --cacert $cacert --cert $cert --key $key 'resources[certname] { type = "Class" and title = "Puppet_enterprise::Profile::Console" }' | grep certname | cut -d '"' -f4)

fi

# set variables
node_is_mom=false

# sanity check: run on PE Mom only
for pe_mom_node in $pe_mom; do
  if [ $pe_mom_node == $certname ]; then
    node_is_mom=true
  fi
done
if [ $node_is_mom == false ]; then
  echo "not running on mom. terminating"
  exit 1
fi

# get list of certificates to remove
nodes=$PT_nodenames

# convert to shell array
IFS='[],' read -r -a array <<< $nodes

# iterate over given nodes
for node in ${array[@]}; do

  # sanity check: do not remove mom certificates
  for pe_mom_node in $pe_mom; do
    if [ "${node//\"}" == $pe_mom_node ]; then
      echo "$node in list is a MoM node. Terminating"
      exit 1
    fi
  done
  # sanity check: do not remove compiler certificates
  for pe_compiler_node in $pe_compiler; do
    if [ "${node//\"}" == $pe_compiler_node ]; then
      echo "$node in list is a compiler node. Terminating"
      exit 1
    fi
  done
  # sanity check: do not remove puppetdb certificates
  for pe_puppetdb_node in $pe_puppetdb; do
    if [ "${node//\"}" == $pe_puppetdb_node ]; then
      echo "$node in list is a puppetdb node. Terminating"
      exit 1
    fi
  done
  # sanity check: do not remove console certificates
  for pe_console_node in $pe_console; do
    if [ "${node//\"}" == $pe_console_node ]; then
      echo "$node in list is a console node. Terminating"
      exit 1
    fi
  done

done

# sanity check finished, lets run the cert removal and cleanup
for node in ${array[@]}; do
  cleannode=${node//\"}
  if [ $(/opt/puppetlabs/puppet/bin/puppet cert list $cleannode | wc -l) -gt 0 ]; then
    echo "Cleaning certificate for $cleannode"
    /opt/puppetlabs/puppet/bin/puppet cert clean $cleannode
    /opt/puppetlabs/puppet/bin/puppet node clean $cleannode
  else
    echo "No certificate found for $cleannode. Skipping."
  fi
  echo "Deactivating $cleannode in PuppetDB"
  /opt/puppetlabs/puppet/bin/puppet node deactivate $cleannode
done

echo "Done."

