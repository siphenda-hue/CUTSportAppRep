-- Add CUT's verified Pool B, Section 2 standings from the 2023 USSA A Cricket tournament.
-- CUT won all three section matches:
-- 143/3 vs Rhodes 142/10; 117/3 vs Nelson Mandela University B 116/10;
-- 350/4 vs Fort Hare 169/10. The published table records 15 points and first place.
-- Run totals are aggregated from the three published scorecards.

insert into public.competition_standings (
  competition_id, team_name, group_name, position, played, won, drawn, lost,
  scored, conceded, points, source_url
)
select
  'a43e3a9b-7c4e-4d7e-9f7c-2023c5a00001',
  'Central University of Technology',
  'Pool B — Section 2',
  1,
  3,
  3,
  0,
  0,
  610,
  427,
  15,
  'https://www.clubcricket.co.za/latestnews/ussa-a-tournament-results-and-scores-7-december-uwc-beat-uj-varsity-college-beat-madibaz-b/'
where not exists (
  select 1
  from public.competition_standings
  where competition_id='a43e3a9b-7c4e-4d7e-9f7c-2023c5a00001'
    and team_name='Central University of Technology'
    and group_name='Pool B — Section 2'
);
