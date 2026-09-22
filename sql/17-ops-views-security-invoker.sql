-- 17-ops-views-security-invoker.sql
-- Fix Supabase advisor finding 0010_security_definer_view on the brain-health
-- ops views (sql/12-brain-health-views.sql). Views are internal dashboards
-- read only via service_role, which bypasses RLS, so switching them to
-- security_invoker changes nothing for the intended reader. anon/authenticated
-- grants inherited from default privileges are revoked.

DO $$
DECLARE v text;
BEGIN
  FOR v IN
    SELECT c.relname FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relkind = 'v' AND c.relname LIKE 'ops\_%'
  LOOP
    EXECUTE format('ALTER VIEW public.%I SET (security_invoker = true)', v);
    EXECUTE format('REVOKE ALL ON public.%I FROM anon, authenticated', v);
    EXECUTE format('GRANT SELECT ON public.%I TO service_role', v);
  END LOOP;
END $$;
