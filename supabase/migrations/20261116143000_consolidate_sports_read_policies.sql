-- Consolidate sports SELECT policies without changing who can read rows.
-- Anonymous users retain active-sport visibility. Authenticated users retain
-- active-sport visibility plus access to sports they are assigned to manage.
DROP POLICY IF EXISTS "Assigned sport admins read managed sports" ON public.sports;
DROP POLICY IF EXISTS "Sports public read" ON public.sports;

CREATE POLICY "Sports public read"
  ON public.sports
  FOR SELECT
  TO anon
  USING (is_active = true);

CREATE POLICY "Authenticated users read active or assigned sports"
  ON public.sports
  FOR SELECT
  TO authenticated
  USING (
    is_active = true
    OR (SELECT private.can_manage_sport(sports.id))
  );
