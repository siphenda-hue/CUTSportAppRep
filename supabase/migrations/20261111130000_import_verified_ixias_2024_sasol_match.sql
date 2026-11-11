-- Import one independently verified 2024 Sasol Women's League match and scorer breakdown.
-- Source: gsport4girls, 28 June 2024 (match played 23 June 2024).
-- https://gsport.co.za/log-leaders-sitting-pretty-in-sasol-womens-league/

insert into public.competition_matches (
  competition_id, source_match_id, starts_at, home_team, away_team,
  home_score, away_score, match_status, match_round, group_name,
  venue, source_url, source_checked_at, statistics
)
select
  '4e8d727d-d04b-4f0c-a37a-e8baec7ec51c'::uuid,
  'gsport-2024-06-23-ixias-napoli',
  '2024-06-23 00:00:00+02'::timestamptz,
  'Ixias FC (CUT)', 'Napoli Ladies FC',
  11, 0, 'completed', 'League fixture', 'Free State Group 1A',
  'CUT Welkom Ground',
  'https://gsport.co.za/log-leaders-sitting-pretty-in-sasol-womens-league/',
  now(),
  jsonb_build_object(
    'scorers', jsonb_build_array(
      jsonb_build_object('player','Masabata Mathapo','goals',6),
      jsonb_build_object('player','Agnes Ramokatsa','goals',2),
      jsonb_build_object('player','Ashley Staal','goals',1),
      jsonb_build_object('player','Makhala Makhanya','goals',1),
      jsonb_build_object('player','Karabelo Tseko','goals',1)
    ),
    'source_note','Published match report; kick-off time not stated'
  )
where not exists (
  select 1 from public.competition_matches
  where competition_id='4e8d727d-d04b-4f0c-a37a-e8baec7ec51c'::uuid
    and source_match_id='gsport-2024-06-23-ixias-napoli'
);

with scorers(player_name, goals) as (
  values
    ('Masabata Mathapo',6),
    ('Agnes Ramokatsa',2),
    ('Ashley Staal',1),
    ('Makhala Makhanya',1),
    ('Karabelo Tseko',1)
)
insert into public.competition_player_statistics (
  competition_id, player_name, team_name, total_goals,
  source_url, source_checked_at, statistics
)
select
  '4e8d727d-d04b-4f0c-a37a-e8baec7ec51c'::uuid,
  s.player_name, 'Ixias FC (CUT)', s.goals,
  'https://gsport.co.za/log-leaders-sitting-pretty-in-sasol-womens-league/',
  now(),
  jsonb_build_object('match_goals',s.goals,'match_date','2024-06-23','opponent','Napoli Ladies FC')
from scorers s
where not exists (
  select 1 from public.competition_player_statistics p
  where p.competition_id='4e8d727d-d04b-4f0c-a37a-e8baec7ec51c'::uuid
    and p.player_name=s.player_name
    and p.team_name='Ixias FC (CUT)'
    and p.source_url='https://gsport.co.za/log-leaders-sitting-pretty-in-sasol-womens-league/'
);

-- Correct the 2025 provincial decider date to the explicitly reported 16 November 2025.
update public.competition_matches
set starts_at='2025-11-16 00:00:00+02'::timestamptz,
    source_checked_at=now()
where competition_id='a5d2485a-39bc-4bbd-9315-16c9aa126463'::uuid
  and home_team='CUT Ixias Ladies'
  and away_team='Napoli Ladies'
  and home_score=5 and away_score=0
  and starts_at::date='2025-11-15';
