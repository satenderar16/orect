-- Enable RLS on all relevant tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.category ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subcategory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.item ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.option ENABLE ROW LEVEL SECURITY;
ALTER TABLE public."order" ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_detail ENABLE ROW LEVEL SECURITY;

-- PROFILES POLICIES
DROP POLICY IF EXISTS "User can insert own profile" ON public.profiles;
CREATE POLICY "User can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "User can update own profile" ON public.profiles;
CREATE POLICY "User can update own profile"
  ON public.profiles FOR UPDATE
  USING (id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "User can select own profile" ON public.profiles;
CREATE POLICY "User can select own profile"
  ON public.profiles FOR SELECT
  USING (id = (SELECT auth.uid()));

-- CATEGORY POLICIES
DROP POLICY IF EXISTS "User insert own category" ON public.category;
CREATE POLICY "User insert own category"
  ON public.category FOR INSERT
  WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "User update own category" ON public.category;
CREATE POLICY "User update own category"
  ON public.category FOR UPDATE
  USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "User select own category" ON public.category;
CREATE POLICY "User select own category"
  ON public.category FOR SELECT
  USING (user_id = (SELECT auth.uid()));

-- SUBCATEGORY POLICIES
DROP POLICY IF EXISTS "User insert subcategory" ON public.subcategory;
CREATE POLICY "User insert subcategory"
  ON public.subcategory FOR INSERT
  WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "User update subcategory" ON public.subcategory;
CREATE POLICY "User update subcategory"
  ON public.subcategory FOR UPDATE
  USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "User select subcategory" ON public.subcategory;
CREATE POLICY "User select subcategory"
  ON public.subcategory FOR SELECT
  USING (user_id = (SELECT auth.uid()));

-- ITEM POLICIES
DROP POLICY IF EXISTS "User insert item" ON public.item;
CREATE POLICY "User insert item"
  ON public.item FOR INSERT
  WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "User update item" ON public.item;
CREATE POLICY "User update item"
  ON public.item FOR UPDATE
  USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "User select item" ON public.item;
CREATE POLICY "User select item"
  ON public.item FOR SELECT
  USING (user_id = (SELECT auth.uid()));

-- OPTION POLICIES
DROP POLICY IF EXISTS "User insert option" ON public.option;
CREATE POLICY "User insert option"
  ON public.option FOR INSERT
  WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "User update option" ON public.option;
CREATE POLICY "User update option"
  ON public.option FOR UPDATE
  USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "User select option" ON public.option;
CREATE POLICY "User select option"
  ON public.option FOR SELECT
  USING (user_id = (SELECT auth.uid()));

-- ORDER POLICIES
DROP POLICY IF EXISTS "User insert order" ON public."order";
CREATE POLICY "User insert order"
  ON public."order" FOR INSERT
  WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "User update pending order" ON public."order";
CREATE POLICY "User update pending order"
  ON public."order" FOR UPDATE
  USING (user_id = (SELECT auth.uid()) AND status = 'pending');

DROP POLICY IF EXISTS "User select own order" ON public."order";
CREATE POLICY "User select own order"
  ON public."order" FOR SELECT
  USING (user_id = (SELECT auth.uid()));

-- ORDER DETAIL POLICIES
DROP POLICY IF EXISTS "User insert order details" ON public.order_detail;
CREATE POLICY "User insert order details"
  ON public.order_detail FOR INSERT
  WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS "User update order details if order is pending" ON public.order_detail;
CREATE POLICY "User update order details if order is pending"
  ON public.order_detail FOR UPDATE
  USING (
    user_id = (SELECT auth.uid()) AND EXISTS (
      SELECT 1 FROM public."order" o
      WHERE o.id = order_detail.order_id AND o.status = 'pending'
    )
  );

DROP POLICY IF EXISTS "User select own order details" ON public.order_detail;
CREATE POLICY "User select own order details"
  ON public.order_detail FOR SELECT
  USING (user_id = (SELECT auth.uid()));
