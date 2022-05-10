#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  declare -r pre_command='sudo '
else
  declare -r pre_command=''
fi



if [[ "x${PT_puppet_source}" != "x" ]]; then
  command -v puppet &>/dev/null || { echo "command puppet not found!" && exit 1; }
  puppet lookup \"${PT_key}\" --node  \"${PT_puppet_source}\", ensure => directory, recurse => true }"
fi

if [[ "x${PT_puppet_source_tgz}" != "x" ]]; then
  command -v puppet &>/dev/null || { echo "command puppet not found!" && exit 1; }
  command -v tar &>/dev/null || { echo "command tar not found!" && exit 1; }
  TMPFILE=`mktemp`
  puppet apply -e "file { \"${TMPFILE}\": source => \"${PT_puppet_source_tgz}\", ensure => present }"
  mkdir -p $PT_destination
  cd $PT_destination
  tar -zvxf $TMPFILE .
  rm -f $TMPFILE
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
