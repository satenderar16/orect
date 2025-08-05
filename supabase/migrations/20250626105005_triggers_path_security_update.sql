-- VERSIONING FUNCTION
CREATE OR REPLACE FUNCTION update_version_and_timestamp()
RETURNS trigger AS $$
BEGIN
  NEW.version := OLD.version + 1;
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public;

-- CATEGORY
CREATE OR REPLACE FUNCTION set_user_id_category()
RETURNS trigger AS $$
BEGIN
  NEW.user_id := auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth;

-- SUBCATEGORY
CREATE OR REPLACE FUNCTION set_user_id_subcategory()
RETURNS trigger AS $$
BEGIN
  NEW.user_id := auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth;

-- ITEM
CREATE OR REPLACE FUNCTION set_user_id_item()
RETURNS trigger AS $$
BEGIN
  NEW.user_id := auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth;

-- OPTION
CREATE OR REPLACE FUNCTION set_user_id_option()
RETURNS trigger AS $$
BEGIN
  NEW.user_id := auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth;

-- ORDER
CREATE OR REPLACE FUNCTION set_order_user_id()
RETURNS trigger AS $$
BEGIN
  NEW.user_id := auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth;

CREATE OR REPLACE FUNCTION set_order_no_per_day()
RETURNS trigger AS $$
DECLARE
  next_order_no INTEGER;
BEGIN
  SELECT COALESCE(MAX(order_no), 0) + 1 INTO next_order_no
  FROM public."order"
  WHERE user_id = NEW.user_id AND DATE(created_at) = DATE(NEW.created_at);
  NEW.order_no := next_order_no;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public;

-- ORDER DETAIL
CREATE OR REPLACE FUNCTION set_user_id_order_details()
RETURNS trigger AS $$
BEGIN
  NEW.user_id := auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth;
