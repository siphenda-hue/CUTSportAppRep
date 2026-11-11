-- Add verified individual bowling figures from CUT's 2018 USSA A Section
-- seventh-place play-off against UCT. Source reports CUT 180, UCT 76.
insert into public.competition_player_statistics
  (competition_id, player_name, team_name, statistics, source_url, source_checked_at)
select
  'a43e3a9b-7c4e-4d7e-9f7c-2018c5a00001'::uuid,
  v.player_name,
  'Central University of Technology',
  jsonb_build_object(
    'wickets', v.wickets,
    'runs_conceded', v.runs_conceded,
    'overs', null,
    'stat_category', 'bowling',
    'match_opponent', 'University of Cape Town',
    'match_date', '2018-12-07'
  ),
  'https://www.sacricketmag.com/tuks-madibaz-b-crowned-ussa-champions/',
  now()
from (values
  ('Nealan van Heerden', 3, 10),
  ('Jason Raubenheimer', 3, 21),
  ('Devon du Plessis', 3, 24)
) as v(player_name, wickets, runs_conceded)
where not exists (
  select 1 from public.competition_player_statistics s
  where s.competition_id = 'a43e3a9b-7c4e-4d7e-9f7c-2018c5a00001'::uuid
    and lower(trim(s.player_name)) = lower(v.player_name)
    and s.team_name = 'Central University of Technology'
);
