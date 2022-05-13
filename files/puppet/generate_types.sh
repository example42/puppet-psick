#!/bin/bash

set -e

for line in $(ls /etc/puppetlabs/code/environments); do
  /opt/puppetlabs/puppet/bin/puppet generate types --environment $line
done

