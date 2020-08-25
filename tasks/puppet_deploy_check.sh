#!/usr/bin/env bash

cd /etc/puppetlabs/code/environments/$PT_environment

[ -f .r10k-deploy.json  ] && cat .r10k-deploy.json | grep deploy_success
[ -f .r10k-deploy.json  ] && cat .r10k-deploy.json | grep signature

git rev-parse HEAD

git log | grep 'deploy signature' | cut -d "'" -f 2
