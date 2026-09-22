-- ============================================================
-- Entity extraction auto-queue trigger
--
-- Problem: schemas/entity-extraction/schema.sql ships a
-- trg_queue_entity_extraction trigger that's supposed to queue every
-- inserted/updated thought for entity extraction, but it was never
-- actually installed on this project's live `thoughts` table. Confirmed
-- 2026-08-04 by inserting a real thought via REST and observing no row
-- appeared in entity_extraction_queue. Nothing captured since 2026-04-28
-- has been queued for extraction as a result.
--
-- This file installs that trigger, but NOT as a copy-paste of the
-- recipe's version — the live entity_extraction_queue table has already
-- drifted from schemas/entity-extraction/schema.sql (verified via the
-- Supabase OpenAPI introspection endpoint, GET /rest/v1/, not by trusting
-- the checked-in file):
--
--   Recipe's schema.sql assumes:  thought_id UUID PRIMARY KEY, attempt_count,
--                                  last_error, source_fingerprint, source_updated_at
--   Actually live:                id UUID PRIMARY KEY (separate from thought_id),
--                                  thought_id UUID (FK, NO unique constraint —
--                                  confirmed by inserting two rows with the same
--                                  thought_id; both succeeded), status,
--                                  created_at, processed_at, error_message,
--                                  metadata, queued_at, started_at, worker_version
--
-- Without a unique constraint on thought_id, ON CONFLICT (thought_id) has
-- nothing to match and would fail at runtime ("no unique or exclusion
-- constraint matching the ON CONFLICT specification"). Step 1 below adds
-- that constraint so re-queuing on update is a clean upsert instead of an
-- unbounded pile of duplicate rows per thought.
--
-- Safe to run more than once (idempotent): the constraint add is guarded,
-- the function is CREATE OR REPLACE, and the trigger is DROP + CREATE.
-- ============================================================

-- 1. Add the unique constraint the live table is missing.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'entity_extraction_queue_thought_id_key'
  ) THEN
    ALTER TABLE public.entity_extraction_queue
      ADD CONSTRAINT entity_extraction_queue_thought_id_key UNIQUE (thought_id);
  END IF;
END $$;

-- 2. Auto-queue function, written against the LIVE column set
--    (error_message, not last_error; no attempt_count / source_fingerprint /
--    source_updated_at columns exist, so those are dropped vs. the recipe).
CREATE OR REPLACE FUNCTION public.queue_entity_extraction()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Skip system-generated artifacts (consolidation outputs, bios, etc.)
  IF NEW.metadata->>'generated_by' IS NOT NULL THEN
    RETURN NEW;
  END IF;

  INSERT INTO public.entity_extraction_queue (thought_id, status)
  VALUES (NEW.id, 'pending')
  ON CONFLICT (thought_id) DO UPDATE SET
    status = 'pending',
    error_message = NULL,
    queued_at = now();

  RETURN NEW;
END;
$$;

-- 3. Attach trigger to thoughts table (fires on insert or content/metadata change).
DROP TRIGGER IF EXISTS trg_queue_entity_extraction ON public.thoughts;
CREATE TRIGGER trg_queue_entity_extraction
  AFTER INSERT OR UPDATE OF content, metadata ON public.thoughts
  FOR EACH ROW
  EXECUTE FUNCTION public.queue_entity_extraction();
