-- Explicitly flag CUT goals whose individual scorers are not identified in the available reports.
UPDATE public.competition_matches
SET statistics = jsonb_set(
  jsonb_set(
    COALESCE(statistics, '{}'::jsonb),
    '{scorers,CUT}',
    '"Not individually attributed in available report (2 CUT goals)"'::jsonb,
    true
  ),
  '{scoring_data_status}',
  '"team_score_verified_individual_scorers_unavailable"'::jsonb,
  true
)
WHERE id = 'dd7e2624-f65b-4e67-80e2-c08b2ae05ddd'
  AND home_team = 'CUT' AND home_score = 2 AND away_team = 'TUT' AND away_score = 6;

UPDATE public.competition_matches
SET statistics = jsonb_set(
  jsonb_set(
    COALESCE(statistics, '{}'::jsonb),
    '{scorers,CUT}',
    '"Not individually attributed in available report (1 CUT goal)"'::jsonb,
    true
  ),
  '{scoring_data_status}',
  '"team_score_verified_individual_scorer_unavailable"'::jsonb,
  true
)
WHERE id = '29f0d09a-90fc-45cb-afb8-666389eeacad'
  AND home_team = 'TUT' AND home_score = 3 AND away_team = 'CUT' AND away_score = 1;