-- Import verified CUT Cricket achievements and USSA representation for 2014.
-- Sources:
-- CUT Annual Report 2014: https://www.cut.ac.za/wp-content/uploads/2013/04/CUT-Annual-Report-2014.pdf
-- The Herald, 8 Dec 2014: https://www.theherald.co.za/sport/2014-12-08-two-east-cape-varsity-players-in-sa-cricket-squad/
-- University of Pretoria USSA event details: https://www.up.ac.za/cricket/event/ussa-cricket-week

insert into public.competitions (
  id, sport_id, name, season, start_date, end_date, venue, description, status
) values
(
  'a43e3a9b-7c4e-4d7e-9f7c-2014c5a00001',
  '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
  'Free State Cricket First Division',
  '2014',
  '2014-01-01',
  '2014-12-31',
  'Free State, South Africa',
  'CUT’s second cricket team won the First Division Tournament in 2014 and earned promotion to the Free State Super League for the 2014/15 season, as recorded in CUT’s 2014 Annual Report. Exact match results, final points table and individual statistics were not available in the source. Source: https://www.cut.ac.za/wp-content/uploads/2013/04/CUT-Annual-Report-2014.pdf',
  'completed'
),
(
  'a43e3a9b-7c4e-4d7e-9f7c-2014c5a00002',
  '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
  'USSA Cricket Tournament',
  '2014',
  '2014-12-01',
  '2014-12-05',
  'University of Johannesburg and University of the Witwatersrand, Johannesburg, South Africa',
  'CUT representation at the December 2014 USSA cricket week is evidenced by Bokang Mosena’s selection as vice-captain of the University Sport South Africa team and Thabo Masheshemane and Tshepo Ntuli being named non-travelling reserves. The event ran 1–5 December 2014 in Johannesburg. CUT’s exact team section, match results and player statistics are not confirmed. Sources: https://www.theherald.co.za/sport/2014-12-08-two-east-cape-varsity-players-in-sa-cricket-squad/ ; https://www.up.ac.za/cricket/event/ussa-cricket-week',
  'completed'
)
on conflict (id) do update set
  sport_id = excluded.sport_id,
  name = excluded.name,
  season = excluded.season,
  start_date = excluded.start_date,
  end_date = excluded.end_date,
  venue = excluded.venue,
  description = excluded.description,
  status = excluded.status;
