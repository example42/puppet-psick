#!/usr/bin/env bash

set -e


# check that we are a mom, get information from puppetdb
if [ ! -e /etc/puppetlabs/puppet/puppetdb.conf ]; then
  echo "not running on a master... terminating"
  exit 1
fi

# get our certificate name
certname=$(/opt/puppetlabs/puppet/bin/puppet agent --configprint certname)

# read puppetdb url from puppetdb.conf file
server=$(grep server /etc/puppetlabs/puppet/puppetdb.conf | cut -d "=" -f2 |sed -e 's/^[ \t]*//')

# get list of nodes classified with puppet_enterprise::profile::master class:
pe_masters=$(puppet query --urls $server --cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem --cert /etc/puppetlabs/puppet/ssl/certs/$certname.pem --key /etc/puppetlabs/puppet/ssl/private_keys/$certname.pem 'resources[certname] { type = "Class" and title = "Puppet_enterprise::Profile::Master" }' | grep certname | cut -d '"' -f4)

# manage your list of PE MoM nodes here
#
#pe_mom='master.razor.demo nod32 node3'
#pe_compiler='master.razor.demo compiler1 compiler2'
#
# or use the computed list:
#
pe_mom=$pe_masters
pe_compiler=$pe_masters


# dont change from here on #
############################

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

  # sanity check: do not remove mom or compiler certificates
  for pe_mom_node in $pe_mom; do
    if [ "${node//\"}" == $pe_mom_node ]; then
      echo "One node in list is a PE MoM. Terminating"
      exit 1
    fi
  done
  for pe_compiler_node in $pe_compiler; do
    if [ "${node//\"}" == $pe_compiler_node ]; then
      echo "One node in list is a compiler node. Terminating"
      exit 1
    fi
  done

done

# sanity check finished, lets run the cert removal and cleanup
for node in ${array[@]}; do
  /opt/puppetlabs/puppet/bin/puppet node clean $node
  /opt/puppetlabs/puppet/bin/puppet node deactivate $node
  /opt/puppetlabs/puppet/bin/puppet cert clean $node
done

