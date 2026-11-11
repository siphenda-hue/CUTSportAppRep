-- Align 2024 Varsity Football scorer metadata with the same-match squad spelling.
UPDATE public.competition_matches
SET statistics = jsonb_set(
  jsonb_set(
    COALESCE(statistics, '{}'::jsonb),
    '{scorers,CUT}',
    '["Nkosingiphile Lubisi", "Pogisho Dikole"]'::jsonb,
    true
  ),
  '{scorer_name_variant_note}',
  '"The scorer line spells the name Libubisi, while the same official report team list spells it Lubisi; canonical spelling is Lubisi."'::jsonb,
  true
)
WHERE id = '18b942ad-7695-4b94-bb61-3e028909d242'
  AND competition_id = 'b8d5f59f-633f-4fc0-8b4b-ff2aa1c2bfc1'
  AND home_team = 'CUT' AND away_team = 'VUT';

UPDATE public.competition_team_statistics
SET statistics = jsonb_set(
  COALESCE(statistics, '{}'::jsonb),
  '{known_named_scorers}',
  (COALESCE(statistics->'known_named_scorers', '{}'::jsonb) - 'Nkosingiphile Libubisi')
    || jsonb_build_object(
      'Nkosingiphile Lubisi',
      COALESCE((statistics->'known_named_scorers'->>'Nkosingiphile Lubisi')::integer, 0)
        + COALESCE((statistics->'known_named_scorers'->>'Nkosingiphile Libubisi')::integer, 0)
    ),
  true
)
WHERE competition_id = 'b8d5f59f-633f-4fc0-8b4b-ff2aa1c2bfc1'
  AND team_name = 'CUT'
  AND statistics->'known_named_scorers' ? 'Nkosingiphile Libubisi';