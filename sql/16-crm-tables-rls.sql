-- 16-crm-tables-rls.sql
-- Fix Supabase advisor finding rls_disabled_in_public (19 Sep 2026) on the
-- crm-person-tiers tables. Matches the service-role-only pattern used on
-- public.thoughts. Tables are only reached via the crm_person_tiers() RPC
-- from server-side (service_role) clients, so this changes nothing for the
-- intended install path. anon/authenticated CRUD grants inherited from the
-- schema's default privileges are revoked as well.

ALTER TABLE public.crm_persons         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crm_person_mentions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Service role full access" ON public.crm_persons;
CREATE POLICY "Service role full access" ON public.crm_persons
  FOR ALL USING (auth.role() = 'service_role');

DROP POLICY IF EXISTS "Service role full access" ON public.crm_person_mentions;
CREATE POLICY "Service role full access" ON public.crm_person_mentions
  FOR ALL USING (auth.role() = 'service_role');

REVOKE ALL ON public.crm_persons, public.crm_person_mentions FROM anon, authenticated;
