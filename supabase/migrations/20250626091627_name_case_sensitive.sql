-- For category
CREATE UNIQUE INDEX IF NOT EXISTS unique_category_user_lower_name
  ON public.category (user_id, LOWER(name));

-- For subcategory
CREATE UNIQUE INDEX IF NOT EXISTS unique_subcategory_user_lower_name
  ON public.subcategory (user_id, LOWER(name));

-- For item
CREATE UNIQUE INDEX IF NOT EXISTS unique_item_user_lower_name
  ON public.item (user_id, LOWER(name));

-- For option
CREATE UNIQUE INDEX IF NOT EXISTS unique_option_item_lower_name
  ON public.option (item_id, LOWER(name));