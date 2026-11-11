-- Import CUT's 2022 Sasol League National Championship record and reconcile 2023.
-- The 2022 CUT magazine's semi-final narrative conflicts with the match-level group table;
-- preserve both claims in the competition description rather than inventing a knockout result.

with comp as (
  insert into public.competitions
    (id, sport_id, name, season, start_date, end_date, venue, description, status)
  values
    ('a43e3a9b-7c4e-4d7e-9f7c-2022a5d00001'::uuid,
     '4c1ccd6f-3965-422a-ad25-19aaa2797f23'::uuid,
     'Sasol League National Championship',
     '2022',
     '2022-10-18',
     '2022-10-23',
     'Old Peter Mokaba Stadium, Polokwane',
     'CUT FC qualified as Free State provincial champions after defeating Ixias FC (CUT Welkom) in the provincial final on 18 September 2022. Match-level tournament results list a 0-3 loss to Tuks Ladies and a 1-1 draw with Sophakama, with CUT third in Group A and not through to the semi-finals. A CUT institutional magazine separately reports that the team reached the semi-finals and were eliminated by Tshwane University of Technology; this conflicts with the match-level group table and remains unresolved. No final tournament placing is asserted.',
     'completed')
  on conflict (id) do update set
    description = excluded.description,
    start_date = excluded.start_date,
    end_date = excluded.end_date,
    venue = excluded.venue,
    status = 'completed'
  returning id
)
insert into public.competition_matches
  (competition_id, source_match_id, starts_at, home_team, away_team,
   home_score, away_score, match_status, match_round, group_name,
   source_url, source_checked_at, statistics)
select comp.id, x.source_match_id, x.starts_at, x.home_team, x.away_team,
       x.home_score, x.away_score, 'completed', x.match_round, 'Group A',
       x.source_url, now(), x.statistics
from comp
cross join (values
  ('2022-sasol-national-cut-match-01',
   '2022-10-19 00:00:00+02'::timestamptz,
   'Tuks Ladies', 'CUT FC', 3, 0, 'Group A — Matchday 2',
   'https://www.rsssf.org/tablesz/zaf-wom2022.html'::text,
   '{"match_date":"2022-10-19"}'::jsonb),
  ('2022-sasol-national-cut-match-02',
   '2022-10-20 00:00:00+02'::timestamptz,
   'CUT FC', 'Sophakama Ladies', 1, 1, 'Group A — Matchday 3',
   'https://www.rsssf.org/tablesz/zaf-wom2022.html'::text,
   '{"match_date":"2022-10-20"}'::jsonb)
) as x(source_match_id, starts_at, home_team, away_team, home_score,
       away_score, match_round, source_url, statistics)
on conflict (competition_id, source_match_id) do update set
  starts_at = excluded.starts_at,
  home_team = excluded.home_team,
  away_team = excluded.away_team,
  home_score = excluded.home_score,
  away_score = excluded.away_score,
  match_status = 'completed',
  match_round = excluded.match_round,
  group_name = excluded.group_name,
  source_url = excluded.source_url,
  source_checked_at = now(),
  statistics = excluded.statistics;

insert into public.competition_standings
  (competition_id, team_name, group_name, position, played, won, drawn, lost,
   scored, conceded, points, source_url, source_checked_at)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2022a5d00001'::uuid,
   'CUT FC', 'Group A', 3, 2, 0, 1, 1, 1, 4, 1,
   'https://www.rsssf.org/tablesz/zaf-wom2022.html', now())
on conflict (competition_id, team_name, group_name) do update set
  position = excluded.position,
  played = excluded.played,
  won = excluded.won,
  drawn = excluded.drawn,
  lost = excluded.lost,
  scored = excluded.scored,
  conceded = excluded.conceded,
  points = excluded.points,
  source_url = excluded.source_url,
  source_checked_at = now(),
  updated_at = now();

update public.competitions
set description = 'CUT Ixias qualified as Free State provincial champions and competed in Group C at the Dr Petrus Molemela Stadium tournament (16–22 October 2023). Match-level results: 1-1 draw with Ramatlaohle Ladies on 18 October; 0-3 loss to University of Cape Town on 19 October. Ixias finished third in Group C with 1 point (2 played, 0 wins, 1 draw, 1 loss, 1 goal for, 4 against) and did not advance to the semi-finals. The tournament finalists were University of Fort Hare and Lindelani Ladies.'
where id = '4397d14f-20e5-48c0-ac0d-26cbb2d1b6fc';
