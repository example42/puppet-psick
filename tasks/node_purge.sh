#!/usr/bin/env bash

# manage your list of PE MoM nodes here
# TODO: switch to PuppetDB query

pe_mom=(master.razor.demo nod32 node3)
pe_compiler=(master.razor.demo compiler1 compiler2)


# dont change from here on #
############################

# set variables
node_is_mom=false

# sanity check: run on PE Mom only
for pe_mom_node in ${pe_mom[@]}; do
  if [ $pe_mom_node == $(/opt/puppetlabs/puppet/bin/puppet agent --configprint certname) ]; then
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
  for pe_mom_node in ${pe_mom[@]}; do
    if [ "${node//\"}" == $pe_mom_node ]; then
      echo "One node in list is a PE MoM. Terminating"
      exit 1
    fi
  done
  for pe_compiler_node in ${pe_compiler[@]}; do
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

