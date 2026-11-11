UPDATE public.competition_team_statistics
SET statistics = COALESCE(statistics, '{}'::jsonb) || jsonb_build_object(
  'scoring_reconciliation_status', 'source_arithmetic_inconsistency',
  'team_total_goals', 14,
  'published_field_goals', 9,
  'published_penalty_corner_goals', 4,
  'published_penalty_stroke_goals', 0,
  'named_player_goals_in_database', 13,
  'unattributed_or_unreconciled_goals', 1,
  'reconciliation_note', 'Official SAHA 2023 Women C-Section page reports 14 CUT team goals, but the published scoring breakdown (9 field goals + 4 penalty-corner goals + 0 penalty strokes) sums to 13. Current named player rows also sum to 13. Preserve source values; do not invent a scorer or silently alter the category breakdown.'
)
WHERE competition_id = '88acbb84-bafc-4b3f-910e-92570303af45'
  AND team_name = 'Central University of Technology';

UPDATE public.competition_player_statistics
SET statistics = COALESCE(statistics, '{}'::jsonb) || jsonb_build_object(
  'season_total_complete', false,
  'team_scoring_reconciliation_note', 'CUT team total is 14 goals, but named player rows sum to 13 and the SAHA category breakdown (9 FG, 4 PC, 0 PS) also sums to 13. One goal remains unreconciled.'
)
WHERE competition_id = '88acbb84-bafc-4b3f-910e-92570303af45'
  AND team_name = 'Central University of Technology';

UPDATE public.competitions
SET description = 'SAHA historical record. CUT finished 2nd in the 2023 Women C-Section. Five match results, final standings and available player goal statistics are recorded. Scoring reconciliation note: SAHA lists 14 team goals, while its category breakdown (9 field goals, 4 penalty corners, 0 penalty strokes) and named player rows each sum to 13; one goal remains unreconciled. Source: https://saha.altiusrt.com/competitions/156'
WHERE id = '88acbb84-bafc-4b3f-910e-92570303af45';