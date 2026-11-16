-- Public season browsing and heritage statistics access
-- Applied to Supabase project tnkykdfxzwaqzbichxcl
-- Migration: 20261116170900_scope_public_seasons_and_preserve_heritage_reads

DROP POLICY IF EXISTS "Competitions public read" ON public.competitions;
CREATE POLICY "Competitions public read"
ON public.competitions
FOR SELECT
TO anon, authenticated
USING (
  (
    season ~ '^[0-9]{4}'
    AND substring(season from '^[0-9]{4}')::integer
        BETWEEN EXTRACT(YEAR FROM CURRENT_DATE)::integer - 1
            AND EXTRACT(YEAR FROM CURRENT_DATE)::integer
  )
  OR name ILIKE '%Varsity Netball%'
  OR name ILIKE '%Varsity Football%'
  OR name ILIKE '%Varsity Cup%'
  OR EXISTS (
    SELECT 1
    FROM public.competition_standings cs
    WHERE cs.competition_id = competitions.id
      AND COALESCE(cs.won, 0) > 0
  )
);

DROP POLICY IF EXISTS "Assigned sport admins manage competition matches"
ON public.competition_matches;
CREATE POLICY "Assigned sport admins manage competition matches"
ON public.competition_matches
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.competitions c
    WHERE c.id = competition_matches.competition_id
      AND c.sport_id IS NOT NULL
      AND private.can_manage_sport(c.sport_id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.competitions c
    WHERE c.id = competition_matches.competition_id
      AND c.sport_id IS NOT NULL
      AND private.can_manage_sport(c.sport_id)
  )
);

DROP POLICY IF EXISTS "Assigned sport admins manage competition player statistics"
ON public.competition_player_statistics;
CREATE POLICY "Assigned sport admins manage competition player statistics"
ON public.competition_player_statistics
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.competitions c
    WHERE c.id = competition_player_statistics.competition_id
      AND c.sport_id IS NOT NULL
      AND private.can_manage_sport(c.sport_id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.competitions c
    WHERE c.id = competition_player_statistics.competition_id
      AND c.sport_id IS NOT NULL
      AND private.can_manage_sport(c.sport_id)
  )
);

DROP POLICY IF EXISTS "Assigned sport admins manage competition team statistics"
ON public.competition_team_statistics;
CREATE POLICY "Assigned sport admins manage competition team statistics"
ON public.competition_team_statistics
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.competitions c
    WHERE c.id = competition_team_statistics.competition_id
      AND c.sport_id IS NOT NULL
      AND private.can_manage_sport(c.sport_id)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.competitions c
    WHERE c.id = competition_team_statistics.competition_id
      AND c.sport_id IS NOT NULL
      AND private.can_manage_sport(c.sport_id)
  )
);
