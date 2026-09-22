-- Stop the enrichment <-> extraction re-queue loop.
--
-- trg_queue_entity_extraction fired on UPDATE OF content, metadata. The
-- enrichment job rewrites metadata (enriched_at, enriched_model, ...) on every
-- thought it touches, which re-queued thoughts whose content never changed --
-- so extraction re-ran and re-billed for identical input and the queue never
-- converged.
--
-- Entity extraction depends on content, not on enrichment bookkeeping. One
-- INSERT-OR-UPDATE trigger cannot express that: a WHEN clause may not
-- reference TG_OP, and OLD is unbound on INSERT. Hence two triggers.

DROP TRIGGER IF EXISTS trg_queue_entity_extraction ON public.thoughts;
DROP TRIGGER IF EXISTS trg_queue_entity_extraction_insert ON public.thoughts;
DROP TRIGGER IF EXISTS trg_queue_entity_extraction_update ON public.thoughts;

-- Every new thought is queued exactly once.
CREATE TRIGGER trg_queue_entity_extraction_insert
  AFTER INSERT ON public.thoughts
  FOR EACH ROW
  EXECUTE FUNCTION queue_entity_extraction();

-- An existing thought is re-queued only when its content actually changes.
-- Metadata-only writes (enrichment) no longer trigger extraction.
CREATE TRIGGER trg_queue_entity_extraction_update
  AFTER UPDATE OF content ON public.thoughts
  FOR EACH ROW
  WHEN (OLD.content IS DISTINCT FROM NEW.content)
  EXECUTE FUNCTION queue_entity_extraction();
