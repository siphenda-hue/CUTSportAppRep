-- Record CUT Cricket's 2012 Free State league achievements.
-- Source: CUT Annual Report 2012, p. 76.
-- The report gives team positions but no lower-division names, scorecards or player stats.

insert into public.competitions (
  id,
  sport_id,
  name,
  season,
  start_date,
  end_date,
  venue,
  description,
  status
)
values (
  'a43e3a9b-7c4e-4d7e-9f7c-2012c5a00003',
  '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
  'Free State Cricket Leagues',
  '2012',
  null,
  null,
  'Free State, South Africa',
  'CUT’s first cricket team finished second on the Free State Super League log in 2012. CUT’s second and third teams won their respective leagues that year. The CUT 2012 Annual Report does not identify the lower-division names, exact fixtures, scorelines or individual player statistics; none are asserted. Source: https://www.cut.ac.za/wp-content/uploads/2013/04/CUT-Annual-Report-2012.pdf',
  'completed'
)
on conflict (id) do update
set
  venue = excluded.venue,
  description = excluded.description,
  status = excluded.status;
