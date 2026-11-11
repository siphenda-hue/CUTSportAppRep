-- Record CUT's verified 2023 USSA A Week bowling leader.
-- Source: Club Cricket, USSA A tournament results and scores (7 December 2023).
insert into public.competition_player_statistics
  (competition_id, player_name, team_name, statistics, source_url, source_checked_at)
select
  'a43e3a9b-7c4e-4d7e-9f7c-2023c5a00001'::uuid,
  'Jason Raubenheimer',
  'Central University of Technology',
  '{"wickets":8,"tournament_wicket_taker_rank":4,"stat_category":"bowling"}'::jsonb,
  'https://www.clubcricket.co.za/latestnews/ussa-a-tournament-results-and-scores-7-december-uwc-beat-uj-varsity-college-beat-madibaz-b/',
  now()
where not exists (
  select 1
  from public.competition_player_statistics
  where competition_id = 'a43e3a9b-7c4e-4d7e-9f7c-2023c5a00001'::uuid
    and lower(trim(player_name)) = lower('Jason Raubenheimer')
    and team_name = 'Central University of Technology'
);
