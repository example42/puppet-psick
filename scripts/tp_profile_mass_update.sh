#!/bin/sh
repo_dir="$(dirname $0)/.."
. "${repo_dir}/scritps/functions"
cd $repo_dir
while read line
do
  a=$(echo $line | cut -f 1 -d ' ')
  b=$(echo $line | cut -f 2 -d ' ')
  rm -f manifests/$a/tp.pp
  rm -f spec/classes/$a/tp_spec.rb
  scritps/tp_profile.generate.sh $a $b
done < scritps/tp_profile_mass_update.txt
