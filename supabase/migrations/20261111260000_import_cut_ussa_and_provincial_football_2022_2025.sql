-- Import verified CUT USSA and provincial Football records for 2022 and 2025.
-- This migration does not infer individual player statistics or unverified match results.

with c22 as (
  insert into public.competitions
    (id, sport_id, name, season, start_date, end_date, venue, description, status)
  values
    ('a43e3a9b-7c4e-4d7e-9f7c-2022f5a00001'::uuid,
     '4c1ccd6f-3965-422a-ad25-19aaa2797f23'::uuid,
     'USSA Football Tournament', '2022', '2022-12-05', '2022-12-09',
     'Secunda, Mpumalanga, South Africa',
     'CUT men and women participated in the USSA Football Tournament in Secunda. The men defeated the University of Venda 1-0 to secure a top-eight place and qualify for the 2023 Varsity Football competition. The women lost 3-4 to the University of KwaZulu-Natal and did not qualify. These are the two specifically documented qualification matches; no final USSA placing is asserted.',
     'completed')
  on conflict (id) do update set
    description = excluded.description,
    venue = excluded.venue,
    start_date = excluded.start_date,
    end_date = excluded.end_date,
    status = excluded.status
  returning id
)
insert into public.competition_matches
  (competition_id, source_match_id, starts_at, home_team, away_team,
   home_score, away_score, match_status, match_round, venue, source_url, statistics)
select
  c22.id, x.source_match_id, null, x.home_team, x.away_team,
  x.home_score, x.away_score, 'completed', 'Varsity Football qualification',
  'Secunda, Mpumalanga, South Africa',
  'https://www.cut.ac.za/news/cut-mens-soccer-team-qualifies-for-the-2023-v',
  x.statistics::jsonb
from c22
cross join (values
  ('cut-men-univen-ussa-2022', 'CUT', 'University of Venda', 1, 0,
   '{"qualification":"CUT secured a top-eight place and qualified for 2023 Varsity Football"}'),
  ('cut-women-ukzn-ussa-2022', 'CUT', 'University of KwaZulu-Natal', 3, 4,
   '{"qualification":"CUT women did not qualify for Varsity Football"}')
) as x(source_match_id, home_team, away_team, home_score, away_score, statistics)
on conflict (competition_id, source_match_id) do update set
  home_score = excluded.home_score,
  away_score = excluded.away_score,
  source_url = excluded.source_url,
  statistics = excluded.statistics,
  updated_at = now();

with c25 as (
  insert into public.competitions
    (id, sport_id, name, season, start_date, end_date, venue, description, status)
  values
    ('a43e3a9b-7c4e-4d7e-9f7c-2025f5a00001'::uuid,
     '4c1ccd6f-3965-422a-ad25-19aaa2797f23'::uuid,
     'USSA Football Tournament', '2025', '2025-12-01', '2025-12-05',
     'University of Pretoria, Pretoria, South Africa',
     'Both CUT men and women participated in the 2025 USSA Football Tournament hosted by the University of Pretoria. The men finished 12th overall and did not qualify for the 2026 Varsity Football competition. The women finished 18th overall and were relegated to the B Section for the 2026 USSA competition. No individual match scores or player statistics are asserted.',
     'completed')
  on conflict (id) do update set
    description = excluded.description,
    venue = excluded.venue,
    start_date = excluded.start_date,
    end_date = excluded.end_date,
    status = excluded.status
  returning id
)
insert into public.competition_standings
  (competition_id, team_name, group_name, position, source_url, source_checked_at)
select c25.id, x.team_name, 'Overall', x.position,
       'https://cms.cut.ac.za/Files/Froala/e1338b1b-1a2c-4dd1-8867-270ca64cbf93.pdf',
       now()
from c25
cross join (values ('CUT Men', 12), ('CUT Women', 18)) as x(team_name, position)
on conflict (competition_id, team_name, group_name) do update set
  position = excluded.position,
  source_url = excluded.source_url,
  source_checked_at = now(),
  updated_at = now();

update public.competitions
set description = 'CUT Ixias Ladies (CUT) represented Free State after winning the provincial Sasol League. CUT finished second in Group B with 4 points (1 win, 1 draw, 1 loss; 4 goals for, 5 against), reached the semi-finals and lost 0-3 to Ramatlaohle Ladies. CUT then finished fourth overall at the 2025 SAFA National Women’s Football Tournament. The fourth-place overall finish is confirmed by the CUT Operational Sport annual report; the Group B and semi-final details remain separately recorded.'
where id = '01645af2-b58b-4d5b-8b93-fcbfcb03b8f1';

insert into public.competition_standings
  (competition_id, team_name, group_name, position, source_url, source_checked_at)
values
  ('a5d2485a-39bc-4bbd-9315-16c9aa126463'::uuid,
   'CUT Ixias Ladies', 'Free State Provincial Champion', 1,
   'https://www.cut.ac.za/news/cut-football-stars-set-for-national-stage-after-sasol-league-victory',
   now())
on conflict (competition_id, team_name, group_name) do update set
  position = excluded.position,
  source_url = excluded.source_url,
  source_checked_at = now(),
  updated_at = now();

insert into public.competition_matches
  (competition_id, source_match_id, starts_at, home_team, away_team,
   home_score, away_score, match_status, match_round, venue, source_url, statistics)
values
  ('a5d2485a-39bc-4bbd-9315-16c9aa126463'::uuid,
   'cut-ixias-napoli-free-state-sasol-final-2025', null,
   'CUT Ixias Ladies', 'Napoli Ladies', 5, 0, 'completed',
   'Free State Provincial Play-off Final', 'Free State, South Africa',
   'https://www.cut.ac.za/news/cut-football-stars-set-for-national-stage-after-sasol-league-victory',
   '{"outcome":"CUT Ixias Ladies crowned Free State Sasol League champions and qualified for SAFA national playoffs"}'::jsonb)
on conflict (competition_id, source_match_id) do update set
  home_score = excluded.home_score,
  away_score = excluded.away_score,
  match_status = 'completed',
  source_url = excluded.source_url,
  statistics = excluded.statistics,
  updated_at = now();
