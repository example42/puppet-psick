#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
  declare -r pre_command='sudo '
else
  declare -r pre_command=''
fi

declare puppet_options
[[ -n "${PT_puppet_master}" ]] && puppet_options="${puppet_options} --master ${PT_puppet_master}"
[[ -n "${PT_puppet_verbose}" ]] && puppet_options="${puppet_options} --verbose"
[[ -n "${PT_puppet_debug}" ]] && puppet_options="${puppet_options} --debug"
[[ -n "${PT_puppet_noop}" ]] && puppet_options="${puppet_options} --noop"
[[ -n "${PT_puppet_no_noop}" ]] && puppet_options="${puppet_options} --no-noop"
[[ -n "${PT_puppet_environment}" ]] && puppet_options="${puppet_options} --environment ${PT_puppet_environment}"
readonly puppet_options

$pre_command /opt/puppetlabs/puppet/bin/puppet agent -t $puppet_options

