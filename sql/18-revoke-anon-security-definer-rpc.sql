-- 18-revoke-anon-security-definer-rpc.sql
-- Fix Supabase advisor warnings anon_security_definer_function_executable /
-- authenticated_security_definer_function_executable. These four SECURITY
-- DEFINER functions are either unscheduled (decay_*), fired by a trigger
-- (queue_entity_extraction) or a service_role Edge Function
-- (lookup_agent_memory_key). Nothing calls them with an API-role key, and
-- default privileges had exposed them at /rest/v1/rpc/<name>.

REVOKE EXECUTE ON FUNCTION public.decay_dok_levels()                FROM anon, authenticated, public;
REVOKE EXECUTE ON FUNCTION public.decay_thought_edges()             FROM anon, authenticated, public;
REVOKE EXECUTE ON FUNCTION public.lookup_agent_memory_key(text)     FROM anon, authenticated, public;
REVOKE EXECUTE ON FUNCTION public.queue_entity_extraction()         FROM anon, authenticated, public;

GRANT EXECUTE ON FUNCTION public.decay_dok_levels()            TO service_role;
GRANT EXECUTE ON FUNCTION public.decay_thought_edges()         TO service_role;
GRANT EXECUTE ON FUNCTION public.lookup_agent_memory_key(text) TO service_role;
GRANT EXECUTE ON FUNCTION public.queue_entity_extraction()     TO service_role;
