-- Record the verified 2025 Free State provincial final score separately from season totals.
-- CUT's official report confirms the 5-0 win over Napoli Ladies but does not name the scorers.
update public.competition_team_statistics
set statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
  'provincial_final_opponent', 'Napoli Ladies',
  'provincial_final_goals', 5,
  'provincial_final_conceded', 0,
  'provincial_final_scorers', 'not_published_in_available_official_report',
  'season_total_goals', 'not_established_from_available_sources'
),
source_url = 'https://www.cut.ac.za/news/cut-football-stars-set-for-national-stage-after-sasol-league-victory',
source_checked_at = now(),
updated_at = now()
where competition_id = 'a5d2485a-39bc-4bbd-9315-16c9aa126463'::uuid
  and team_name = 'CUT Ixias Ladies';