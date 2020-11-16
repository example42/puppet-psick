#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
  declare -r pre_command='sudo '
else
  declare -r pre_command=''
fi

declare puppet_options
puppet_options="--detailed-exitcodes"
[[ -n "${PT_verbose}" ]] && puppet_options="${puppet_options} --verbose"
[[ -n "${PT_debug}" ]] && puppet_options="${puppet_options} --debug"
[[ -n "${PT_noop}" ]] && puppet_options="${puppet_options} --noop"
[[ -n "${PT_no_noop}" ]] && puppet_options="${puppet_options} --no-noop"
[[ -n "${PT_tags}" ]] && puppet_options="${puppet_options} --tags ${PT_tags}"
[[ -n "${PT_modulepath}" ]] && puppet_options="${puppet_options} --modulepath ${PT_modulepath}"
readonly puppet_options

$pre_command /opt/puppetlabs/puppet/bin/puppet apply -t $puppet_options $PT_manifest


result=$?
# Puppet exit codes 0 and 2 both imply an error less run
if [ "x$result" == "x0" ] || [ "x$result" == "x2" ]; then
  exit 0
else
  exit 1
fi
