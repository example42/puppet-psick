#!/bin/sh
repo_dir="$(dirname $0)/.."
. "${repo_dir}/bin/functions"
cd $repo_dir
for a in $(cat bin/tp_profile_mass_update.txt); do
  rm -f manifests/$a/tp.pp
  rm -f spec/classes/$a/tp_spec.rb
  bin/tp_profile.generate.sh $a
done
