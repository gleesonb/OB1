-- Writers set metadata.source_type / metadata.source but leave the top-level
-- source_type column null. Fill it at write time and backfill existing rows.
CREATE OR REPLACE FUNCTION public.set_source_type_from_metadata()
RETURNS trigger AS $$
BEGIN
  IF NEW.source_type IS NULL THEN
    NEW.source_type := coalesce(NEW.metadata->>'source_type', NEW.metadata->>'source');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_set_source_type ON public.thoughts;
CREATE TRIGGER trg_set_source_type
  BEFORE INSERT OR UPDATE ON public.thoughts
  FOR EACH ROW
  EXECUTE FUNCTION public.set_source_type_from_metadata();

UPDATE public.thoughts
SET source_type = coalesce(metadata->>'source_type', metadata->>'source')
WHERE source_type IS NULL
  AND coalesce(metadata->>'source_type', metadata->>'source') IS NOT NULL;
