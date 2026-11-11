-- Import CUT Cricket's verified 2012 USSA tournament participation.
-- CUT's 2012 Annual Report confirms three wins and two losses in Cape Town,
-- enough to retain A Section status for the 2013 tournament. Opponents,
-- match dates, scorelines and player statistics are not published in the
-- accessible report and are intentionally not inferred.

insert into public.competitions
  (id, sport_id, name, season, start_date, end_date, venue, description, status)
values (
  'a43e3a9b-7c4e-4d7e-9f7c-2012c5a00001'::uuid,
  '481726ef-be80-4f8e-a0c4-c5f8c41a0f74'::uuid,
  'USSA Cricket Tournament',
  '2012',
  null,
  null,
  'Cape Town, Western Cape, South Africa',
  'CUT Cricket competed in the USSA Cricket Tournament in Cape Town in December 2012. CUT won three matches and lost two, which was sufficient to retain its place in the A Section for the 2013 tournament. The available CUT Annual Report does not identify opponents, individual match dates, scorelines or player statistics; none are asserted.',
  'completed'
)
on conflict (id) do nothing;
