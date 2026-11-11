-- Reconcile the 2025 Varsity Football Round 1 CUT scorer with the official match report.
-- The official Varsity Sports report names Nkosingiphile Lubisi as CUT's scorer in the 4-1 loss to Wits.
UPDATE public.competition_matches
SET statistics =
  jsonb_set(
    jsonb_set(
      COALESCE(statistics, '{}'::jsonb),
      '{scorers,CUT}',
      '["Nkosingiphile Lubisi"]'::jsonb,
      true
    ),
    '{scorer_source_note}',
    '"Official Varsity Sports Round 1 report explicitly names Nkosingiphile Lubisi as CUT scorer."'::jsonb,
    true
  )
WHERE id = 'd5345eed-a7b8-4453-b1bf-729199dcb0a6'
  AND competition_id = 'f925858a-c2e2-4622-903f-913646f6ca71'
  AND home_team = 'Wits'
  AND away_team = 'CUT'
  AND home_score = 4
  AND away_score = 1;

