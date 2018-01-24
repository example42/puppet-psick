#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
  declare -r pre_command='sudo '
else
  declare -r pre_command=''
fi

declare puppet_options
puppet_options="--detailed-exitcodes"
[[ -n "${PT_puppet_master}" ]] && puppet_options="${puppet_options} --server ${PT_puppet_master}"
[[ -n "${PT_verbose}" ]] && puppet_options="${puppet_options} --verbose"
[[ -n "${PT_debug}" ]] && puppet_options="${puppet_options} --debug"
[[ -n "${PT_noop}" ]] && puppet_options="${puppet_options} --noop"
[[ -n "${PT_no_noop}" ]] && puppet_options="${puppet_options} --no-noop"
[[ -n "${PT_environment}" ]] && puppet_options="${puppet_options} --environment ${PT_environment}"
readonly puppet_options

$pre_command /opt/puppetlabs/puppet/bin/puppet agent -t $puppet_options

result=$?
# Puppet exit codes 0 and 2 both imply an error less run
if [ "x$result" == "x0" ] || [ "x$result" == "x2" ]; then
  exit 0
else
  exit 1
fi
