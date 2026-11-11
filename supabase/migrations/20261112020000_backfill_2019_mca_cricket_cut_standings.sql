-- Backfill CUT's two teams in the 2019 Mangaung Cricket Association
-- regular-season log. The published UFS table supplies the match totals and
-- points. CUT 1's 8 played vs 3 wins + 4 losses + 0 no-results leaves one
-- result unclassified in the source; retain the source's published tally and
-- do not guess whether that match was a tie or another outcome.

insert into public.competition_standings (
  competition_id, team_name, position, played, won, drawn, lost,
  bonus_points, points, source_url
)
select
  'a43e3a9b-7c4e-4d7e-9f7c-2019c5a00002',
  'CUT 1',
  6,
  8,
  3,
  0,
  4,
  3,
  39,
  'https://www.ufs.ac.za/KovsieSport/kovsie-sport-divisions/cricket-home/cricket/mca-cricket-league'
where not exists (
  select 1 from public.competition_standings
  where competition_id='a43e3a9b-7c4e-4d7e-9f7c-2019c5a00002'
    and team_name='CUT 1'
);

insert into public.competition_standings (
  competition_id, team_name, position, played, won, drawn, lost,
  bonus_points, points, source_url
)
select
  'a43e3a9b-7c4e-4d7e-9f7c-2019c5a00002',
  'CUT 2',
  7,
  8,
  0,
  0,
  6,
  0,
  26,
  'https://www.ufs.ac.za/KovsieSport/kovsie-sport-divisions/cricket-home/cricket/mca-cricket-league'
where not exists (
  select 1 from public.competition_standings
  where competition_id='a43e3a9b-7c4e-4d7e-9f7c-2019c5a00002'
    and team_name='CUT 2'
);
