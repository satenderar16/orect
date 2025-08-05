CREATE OR REPLACE FUNCTION update_version_and_handle_soft_delete()
RETURNS trigger AS $$
BEGIN
  -- Increment version and update timestamp
  NEW.version := OLD.version + 1;
  NEW.updated_at := now();

  -- Handle soft delete timestamp
  IF NEW.deleted AND NEW.deleted_at IS NULL THEN
    NEW.deleted_at := now();
  ELSIF NOT NEW.deleted THEN
    -- Optional: reset deleted_at if undeleting
    NEW.deleted_at := NULL;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- CATEGORY
DROP TRIGGER IF EXISTS trg_update_category_version ON public.category;
CREATE TRIGGER trg_update_category_version
BEFORE UPDATE ON public.category
FOR EACH ROW
EXECUTE FUNCTION update_version_and_handle_soft_delete();

-- SUBCATEGORY
DROP TRIGGER IF EXISTS trg_update_subcategory_version ON public.subcategory;
CREATE TRIGGER trg_update_subcategory_version
BEFORE UPDATE ON public.subcategory
FOR EACH ROW
EXECUTE FUNCTION update_version_and_handle_soft_delete();

-- ITEM
DROP TRIGGER IF EXISTS trg_update_items_version ON public.item;
CREATE TRIGGER trg_update_items_version
BEFORE UPDATE ON public.item
FOR EACH ROW
EXECUTE FUNCTION update_version_and_handle_soft_delete();

-- OPTION
DROP TRIGGER IF EXISTS trg_update_options_version ON public.option;
CREATE TRIGGER trg_update_options_version
BEFORE UPDATE ON public.option
FOR EACH ROW
EXECUTE FUNCTION update_version_and_handle_soft_delete();

-- ORDER
DROP TRIGGER IF EXISTS trg_update_order_version ON public."order";
CREATE TRIGGER trg_update_order_version
BEFORE UPDATE ON public."order"
FOR EACH ROW
EXECUTE FUNCTION update_version_and_handle_soft_delete();

-- ORDER DETAIL
DROP TRIGGER IF EXISTS trg_update_order_details_version ON public.order_detail;
CREATE TRIGGER trg_update_order_details_version
BEFORE UPDATE ON public.order_detail
FOR EACH ROW
EXECUTE FUNCTION update_version_and_handle_soft_delete();

--//older update_version_and_timestamp trigger without the set deleted
DROP FUNCTION IF EXISTS update_version_and_timestamp;
