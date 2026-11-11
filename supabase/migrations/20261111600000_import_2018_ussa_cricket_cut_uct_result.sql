-- Import the verified CUT result from the 2018 USSA Cricket A Section.
-- The tournament roster confirms 3–7 December 2018 in Stellenbosch.
-- Contemporary cricket reporting confirms CUT beat UCT by 104 runs in the Section A classification match.
-- CricketArchive identifies the fixture as the 7th-place play-off on 7 December.
-- Innings totals and named CUT bowling figures are retained as published; no batting scorecard is inferred.

begin;

insert into public.competitions (
  id, sport_id, name, season, start_date, end_date, venue, description
)
values (
  'a43e3a9b-7c4e-4d7e-9f7c-2018c5a00001',
  '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
  'USSA Cricket Tournament',
  '2018',
  '2018-12-03',
  '2018-12-07',
  'Stellenbosch, Western Cape, South Africa',
  'CUT Cricket competed in the USSA Cricket A Section in Stellenbosch from 3–7 December 2018. In the 7th-place play-off, CUT defeated UCT by 104 runs, scoring 180 before dismissing UCT for 76. CUT bowlers Nealan van Heerden (3/10), Jason Raubenheimer (3/21) and Devon du Plessis (3/24) each took three wickets. No broader final placing or additional match results are asserted.'
)
on conflict (id) do update
set
  name = excluded.name,
  season = excluded.season,
  start_date = excluded.start_date,
  end_date = excluded.end_date,
  venue = excluded.venue,
  description = excluded.description;

insert into public.competition_matches (
  competition_id,
  source_match_id,
  starts_at,
  home_team,
  away_team,
  home_score,
  away_score,
  match_status,
  match_round,
  venue,
  source_url,
  statistics
)
values (
  'a43e3a9b-7c4e-4d7e-9f7c-2018c5a00001',
  'ussa-cricket-2018-cut-vs-uct-7th-place-playoff',
  '2018-12-07T00:00:00',
  'CUT',
  'UCT',
  180,
  76,
  'completed',
  '7th-place play-off',
  'Stellenbosch, Western Cape, South Africa',
  'https://www.sacricketmag.com/tuks-madibaz-b-crowned-ussa-champions/',
  '{"result":"CUT won by 104 runs","cut_innings_total":180,"uct_innings_total":76,"cut_bowlers":[{"name":"Nealan van Heerden","wickets":3,"runs_conceded":10},{"name":"Jason Raubenheimer","wickets":3,"runs_conceded":21},{"name":"Devon du Plessis","wickets":3,"runs_conceded":24}],"scorecard_available":false}'::jsonb
)
on conflict (competition_id, source_match_id) do update
set
  starts_at = excluded.starts_at,
  home_team = excluded.home_team,
  away_team = excluded.away_team,
  home_score = excluded.home_score,
  away_score = excluded.away_score,
  match_status = excluded.match_status,
  match_round = excluded.match_round,
  venue = excluded.venue,
  source_url = excluded.source_url,
  statistics = excluded.statistics;

commit;
