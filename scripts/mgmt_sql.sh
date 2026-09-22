#!/bin/bash
# usage: mgmt_sql.sh <sqlfile|-> ; runs SQL via Supabase Management API
: "${TMPDIR_JSON:=/tmp/ob-q-$$.json}"
TOKEN=$(tr -d '\n' < ~/.supabase/access-token)
REF=zpeedfgyuusscsrirzsg
if [ "$1" = "-" ]; then SQL=$(cat); else SQL=$(cat "$1"); fi
python3 - "$SQL" <<'PY' > "$TMPDIR_JSON"
import json,sys; print(json.dumps({"query": sys.argv[1]}))
PY
curl -s -m 590 -X POST "https://api.supabase.com/v1/projects/$REF/database/query" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" --data-binary @"$TMPDIR_JSON"
