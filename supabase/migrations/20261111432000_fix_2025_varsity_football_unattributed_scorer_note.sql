-- Ensure the scorer object exists before writing the CUT scorer note.
UPDATE public.competition_matches
SET statistics = jsonb_set(
  COALESCE(statistics, '{}'::jsonb),
  '{scorers}',
  COALESCE(statistics->'scorers', '{}'::jsonb)
    || jsonb_build_object('CUT', 'Not individually attributed in available report (1 CUT goal)'),
  true
)
WHERE id = '29f0d09a-90fc-45cb-afb8-666389eeacad'
  AND home_team = 'TUT' AND home_score = 3 AND away_team = 'CUT' AND away_score = 1;