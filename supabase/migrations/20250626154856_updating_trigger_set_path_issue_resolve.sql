CREATE OR REPLACE FUNCTION public.update_version_and_handle_soft_delete()
RETURNS trigger AS $$
BEGIN
  -- Increment version and update timestamp
  NEW.version := OLD.version + 1;
  NEW.updated_at := now();

  -- Handle soft delete timestamp
  IF NEW.deleted AND NEW.deleted_at IS NULL THEN
    NEW.deleted_at := now();
  ELSIF NOT NEW.deleted THEN
    -- Optional: clear deleted_at when undeleting
    NEW.deleted_at := NULL;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql
--  Set secure and immutable search_path
SET search_path = public, pg_temp;