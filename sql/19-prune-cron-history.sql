-- 19-prune-cron-history.sql
-- cron.job_run_details grows one row per run and nothing prunes it. With the
-- entity-extraction-worker firing every minute it reached 21k rows / 12 MB in
-- two weeks on a 500 MB free-tier project. Keep 7 days, prune weekly
-- (Supabase's own recommendation for pg_cron).

SELECT cron.unschedule('prune-cron-history')
WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'prune-cron-history');

SELECT cron.schedule(
  'prune-cron-history',
  '15 3 * * 0',
  $$DELETE FROM cron.job_run_details WHERE end_time < now() - interval '7 days'$$
);
