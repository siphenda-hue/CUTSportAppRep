UPDATE public.competition_team_statistics
SET statistics = COALESCE(statistics, '{}'::jsonb) || jsonb_build_object(
  'player_goal_attribution_status', 'partial_reconciliation_required',
  'documented_named_player_goals', 17,
  'team_tournament_goals', 19,
  'unattributed_goal_difference', 2,
  'reconciliation_note', 'The nine CUT player rows currently total 17 goals (10 field goals and 7 penalty-corner goals), while the official team scoring summary and five recorded match scores total 19 (11 field goals and 8 penalty-corner goals). Two goals remain unattributed to named players in the current player dataset. Do not inflate individual player totals.'
)
WHERE competition_id = '214bf062-b5f3-460f-8564-e2db39f3dff0'
  AND team_name = 'Central University of Technology';

UPDATE public.competition_player_statistics
SET statistics = COALESCE(statistics, '{}'::jsonb) || jsonb_build_object(
  'season_total_complete', false,
  'team_total_reconciliation_note', 'CUT team scored 19 tournament goals; named CUT player rows currently account for 17. Two goals remain unattributed in the current player dataset.'
)
WHERE competition_id = '214bf062-b5f3-460f-8564-e2db39f3dff0'
  AND team_name = 'Central University of Technology';

UPDATE public.competitions
SET description = 'SAHA 2026 USSA Women B-Section. CUT finished 5th overall. All five CUT match results and the final standing are recorded. CUT scored 19 team goals (11 field goals, 8 penalty-corner goals); the nine currently recorded named-player rows account for 17, leaving two goals unattributed pending further source verification. Official SAHA source: https://saha.altiusrt.com/index.php/competitions/265'
WHERE id = '214bf062-b5f3-460f-8564-e2db39f3dff0';