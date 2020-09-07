#!/usr/bin/env bash
environment=${PT_environment:-production}
cd /etc/puppetlabs/code/environments/$environment

[ -f .r10k-deploy.json  ] && cat .r10k-deploy.json | grep deploy_success
[ -f .r10k-deploy.json  ] && cat .r10k-deploy.json | grep signature

git rev-parse HEAD

git log | grep 'deploy signature' | cut -d "'" -f 2
