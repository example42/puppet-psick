#!/usr/bin/env bash
declare -r agent_catalog_run_lockfile=$(puppet config print agent_catalog_run_lockfile)
declare -r agent_disabled_lockfile=$(puppet config print agent_disabled_lockfile)
rm -f $agent_catalog_run_lockfile
rm -f $agent_disabled_lockfile
