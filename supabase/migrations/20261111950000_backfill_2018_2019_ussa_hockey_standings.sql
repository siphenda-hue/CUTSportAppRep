-- Backfill CUT's verified final standings for the 2018 and 2019 USSA men's hockey tournaments.
-- 2018 values are from the official SAHA AltiusRT standings.
-- 2019 overall record and goal totals are reconciled from the five official match results;
-- the published overall table confirms CUT's fifth-place finish.

insert into public.competition_standings (
  competition_id, team_name, position, group_name,
  played, won, drawn, lost, scored, conceded,
  points_difference, points, source_url
)
select
  'b8182018-0000-4000-8000-000000000039',
  'Central University of Technology',
  6, 'Pool A',
  5, 0, 0, 5, 0, 25,
  -25, 0,
  'https://saha.altiusrt.com/competitions/39'
where not exists (
  select 1 from public.competition_standings
  where competition_id='b8182018-0000-4000-8000-000000000039'
    and team_name='Central University of Technology'
);

update public.competition_standings
set position=6, group_name='Pool A', played=5, won=0, drawn=0, lost=5,
    scored=0, conceded=25, points_difference=-25, points=0,
    source_url='https://saha.altiusrt.com/competitions/39'
where competition_id='b8182018-0000-4000-8000-000000000039'
  and team_name='Central University of Technology';

insert into public.competition_standings (
  competition_id, team_name, position, group_name,
  played, won, drawn, lost, scored, conceded,
  points_difference, points, source_url
)
select
  'b8192019-0000-4000-8000-000000000080',
  'Central University of Technology',
  5, null,
  5, 2, 1, 2, 29, 23,
  6, 7,
  'https://saha.altiusrt.com/competitions/80'
where not exists (
  select 1 from public.competition_standings
  where competition_id='b8192019-0000-4000-8000-000000000080'
    and team_name='Central University of Technology'
);

update public.competition_standings
set position=5, group_name=null, played=5, won=2, drawn=1, lost=2,
    scored=29, conceded=23, points_difference=6, points=7,
    source_url='https://saha.altiusrt.com/competitions/80'
where competition_id='b8192019-0000-4000-8000-000000000080'
  and team_name='Central University of Technology';
