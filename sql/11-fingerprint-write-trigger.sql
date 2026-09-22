CREATE OR REPLACE FUNCTION set_content_fingerprint()
RETURNS trigger AS $$
BEGIN
  -- Compute on insert when the caller didn't supply one, and recompute on
  -- update ONLY when the content actually changed (so metadata-only updates
  -- stay cheap and never touch the fingerprint).
  IF NEW.content IS NOT NULL AND (
       NEW.content_fingerprint IS NULL
       OR (TG_OP = 'UPDATE' AND NEW.content IS DISTINCT FROM OLD.content)
     ) THEN
    NEW.content_fingerprint := encode(sha256(convert_to(
      lower(trim(regexp_replace(NEW.content, '\s+', ' ', 'g'))),
      'UTF8'
    )), 'hex');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_set_content_fingerprint ON thoughts;
CREATE TRIGGER trg_set_content_fingerprint
  BEFORE INSERT OR UPDATE ON thoughts
  FOR EACH ROW
  EXECUTE FUNCTION set_content_fingerprint();

-- One-time backfill: touching content fires the trigger for rows still missing a fingerprint.
UPDATE public.thoughts SET content = content WHERE content_fingerprint IS NULL AND content IS NOT NULL;
