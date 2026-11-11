-- Import CUT's two-team participation and published 2019 MCA league figures.
-- Source: University of the Free State MCA Cricket League standings:
-- https://www.ufs.ac.za/KovsieSport/kovsie-sport-divisions/cricket-home/cricket/mca-cricket-league
--
-- The source's CUT 1 row lists 8 played, 3 wins, 4 losses and 0 no-results.
-- Those outcomes account for only 7 of 8 matches; preserve the source values
-- and flag the discrepancy rather than inventing an outcome or position.

insert into public.competitions (
  id, sport_id, name, season, start_date, end_date, venue, description, status
)
values (
  'a43e3a9b-7c4e-4d7e-9f7c-2019c5a00002',
  '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
  'Mangaung Cricket Association League',
  '2019',
  null,
  null,
  'Bloemfontein, Free State, South Africa',
  'CUT entered two teams in the 2019 Mangaung Cricket Association League. The published MCA standings list CUT 1 with 8 matches played, 3 wins, 4 losses, 3 bonus points and 39 total points; the same source reports 0 no-results, leaving one of the eight matches unexplained in the win/loss/no-result tally. CUT 2 recorded 8 played, 0 wins, 6 losses, 2 no-results, 0 bonus points and 26 points. UFS 1 topped the regular league table and was identified as the 2019 Premier League winner. Exact match scorecards, CUT team positions and player statistics are not established by the accessible table. Source: https://www.ufs.ac.za/KovsieSport/kovsie-sport-divisions/cricket-home/cricket/mca-cricket-league',
  'completed'
)
on conflict (id) do update set
  name = excluded.name,
  season = excluded.season,
  venue = excluded.venue,
  description = excluded.description,
  status = excluded.status;
