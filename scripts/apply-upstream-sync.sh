#!/bin/bash
# Applies the Sep-2026 upstream sync SQL to the live Open Brain DB via the Supabase Management API.
# Run from the repo root. Requires ~/.supabase/access-token.
set -e
S=$(dirname "$0"); export TMPDIR_JSON=/tmp/ob-q-$$.json
for f in sql/11-fingerprint-write-trigger.sql recipes/brain-health-monitoring/ops-views.sql schemas/thought-work-claims/schema.sql schemas/per-agent-identity/schema.sql schemas/crm-person-tiers/schema.sql; do
  echo "== $f"; "$S/mgmt_sql.sh" "$f" | head -c 300; echo
done
