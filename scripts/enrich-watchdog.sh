#!/bin/bash
# Hourly watchdog: (re)start thought enrichment if it is not running.
# Safe to run repeatedly: exits immediately if an --apply run is alive; when
# nothing is left to enrich the script itself exits after a couple of REST calls.
DIR=/home/ubuntu/open-brain-v2/recipes/thought-enrichment
LOG=$DIR/logs/enrich-apply.log
LOCK=/home/ubuntu/.cache/enrich-watchdog.lock
mkdir -p $DIR/logs /home/ubuntu/.cache
cd "$DIR" || exit 1
if pgrep -f 'enrich-thoughts.mjs --apply' >/dev/null; then
  echo "$(date -Is) watchdog: enrichment already running" >> "$LOG"; exit 0
fi
echo "$(date -Is) watchdog: starting enrichment" >> "$LOG"
exec flock -n "$LOCK" /home/ubuntu/.nvm/versions/node/v24.16.0/bin/node enrich-thoughts.mjs --apply --concurrency 8 >> "$LOG" 2>&1
