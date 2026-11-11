-- Record CUT Cricket's 2023 Mangaung Cricket Association participation.
-- Source: CUT 2023 Annual Report, section 7.14.6, p. 190.
-- The report confirms participation but publishes no MCA standings, match results,
-- scorecards, or individual player statistics. Do not infer missing results.

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
  'a43e3a9b-7c4e-4d7e-9f7c-2023c5a00002',
  '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
  'Mangaung Cricket Association League',
  '2023',
  null,
  null,
  'Bloemfontein, Free State, South Africa',
  'CUT Cricket participated in the Mangaung Cricket Association (MCA) League during the 2023 reporting year, as confirmed by the CUT 2023 Annual Report. The report does not publish CUT team positions, match results, scorecards or individual player statistics; none are asserted. The same report separately records CUT participation in the Free State Cricket League and first-round participation by the men’s and women’s teams in the Free State Cricket Union League. Source: https://cms.cut.ac.za/Files/Froala/dce12fb4-9f02-488d-b89a-685cce45d2e6.pdf',
  'completed'
)
on conflict (id) do update
set
  venue = excluded.venue,
  description = excluded.description,
  status = excluded.status;
