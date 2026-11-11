-- Record CUT Cricket's verified 2013 Free State league achievements.
-- Source: CUT Annual Report 2013. The report does not provide match-level detail.

insert into public.competitions (
  id, sport_id, name, season, start_date, end_date, venue, description, status
) values (
  'a43e3a9b-7c4e-4d7e-9f7c-2013c5a00001',
  '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
  'Free State Super League',
  '2013',
  null,
  null,
  'Free State, South Africa',
  'CUT Cricket first team finished second in the Free State Super League in 2013. CUT second and third teams won their respective leagues in the same year, as recorded in the CUT Annual Report 2013. Exact league fixtures, match scores, player statistics and the names of the lower divisions are not provided by the report.',
  'completed'
)
on conflict (id) do update set
  name = excluded.name,
  season = excluded.season,
  venue = excluded.venue,
  description = excluded.description,
  status = excluded.status;
