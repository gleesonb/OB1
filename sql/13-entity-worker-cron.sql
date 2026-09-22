-- Schedule the entity-extraction-worker Edge Function via pg_cron + pg_net.
-- The access key is read from Supabase Vault (secret name: mcp_access_key); no secret in this file.
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

SELECT cron.unschedule(jobid) FROM cron.job WHERE jobname = 'entity-extraction-worker';

SELECT cron.schedule(
  'entity-extraction-worker',
  '* * * * *',
  $job$
  SELECT net.http_post(
    url := 'https://zpeedfgyuusscsrirzsg.supabase.co/functions/v1/entity-extraction-worker?limit=12',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-brain-key', (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'mcp_access_key' LIMIT 1)
    ),
    body := '{}'::jsonb,
    timeout_milliseconds := 120000
  );
  $job$
);
