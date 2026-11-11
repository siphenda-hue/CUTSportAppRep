-- Synchronise the 2024 Varsity Football match and team-summary metadata
-- with the user-confirmed identity alias Pule Thekiso = Pule Macdonald Thekiso.
UPDATE public.competition_matches
SET statistics = jsonb_set(
  jsonb_set(
    COALESCE(statistics, '{}'::jsonb),
    '{scorers,CUT}',
    '["Pule Macdonald Thekiso"]'::jsonb,
    true
  ),
  '{scorer_identity_note}',
  '"Source report names the scorer as Pule Thekiso; user confirmed this is Pule Macdonald Thekiso."'::jsonb,
  true
)
WHERE id = '9ae4343e-28e8-411a-9465-8d94301fdd05'
  AND competition_id = 'b8d5f59f-633f-4fc0-8b4b-ff2aa1c2bfc1'
  AND home_team = 'TUT' AND away_team = 'CUT';

UPDATE public.competition_team_statistics
SET statistics = jsonb_set(
  COALESCE(statistics, '{}'::jsonb),
  '{known_named_scorers}',
  (COALESCE(statistics->'known_named_scorers', '{}'::jsonb) - 'Pule Thekiso')
    || jsonb_build_object(
      'Pule Macdonald Thekiso',
      COALESCE((statistics->'known_named_scorers'->>'Pule Macdonald Thekiso')::integer, 0)
        + COALESCE((statistics->'known_named_scorers'->>'Pule Thekiso')::integer, 0)
    ),
  true
)
WHERE competition_id = 'b8d5f59f-633f-4fc0-8b4b-ff2aa1c2bfc1'
  AND team_name = 'CUT'
  AND statistics->'known_named_scorers' ? 'Pule Thekiso';