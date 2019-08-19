#!/usr/bin/env bash
repo_dir="$(dirname $0)/.."
. "${repo_dir}/bin/functions"
app=${1:-undef}
repo=${2:-https://github.com/example42/pdk-module-template-psick-base-profile}

show_help () {
cat << EOF

This script wraps pdk (Puppet Development Kit) to create a new base profile.
It requires the pdk command from Puppet Development Kit (https://docs.puppet.com/pdk/)
You must specify the name of the base profile name and an optional source git repo.
The default template used is: https://github.com/example42/pdk-module-template-psick-base-profile

Usage:
$0 <app> [repo]
EOF
}

if [ "x${app}" == "xundef" ]; then
  show_help
  exit 1
fi

if [ ! -z $(which pdk) ]; then
  echo_title "Creating a new psick profile class with pdk"
  cd $repo_dir
  pdk new class --template-url=$repo $app
else
  show_help
fi

