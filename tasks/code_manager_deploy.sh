#!/usr/bin/env bash

set -e
/opt/puppetlabs/puppet/bin/puppet code deploy $PT_environment --wait

