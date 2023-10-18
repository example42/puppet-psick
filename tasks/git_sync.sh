#!/usr/bin/env bash
cron_safe_path=$(echo "$PT_path" | tr './' '_')
/usr/local/bin/sync_$cron_safe_path
