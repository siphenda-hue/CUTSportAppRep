-- Record CUT Cricket's confirmed participation in the 2021 MCA Leagues.
-- Source: CUT Annual Report 2021, section 6.8.5:
-- https://cms.cut.ac.za/Files/Froala/70c49386-3bd3-416b-8683-ba6f29bd7f4d.pdf
-- The report confirms October-November participation but publishes no standings,
-- match scorecards or individual player statistics.

insert into public.competitions (
  id, sport_id, name, season, start_date, end_date, venue, description, status
)
values (
  'a43e3a9b-7c4e-4d7e-9f7c-2021c5a00002',
  '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
  'Mangaung Cricket Association League',
  '2021',
  '2021-10-01',
  '2021-11-30',
  'Bloemfontein, Free State, South Africa',
  'CUT Cricket participated in the Mangaung Cricket Association (MCA) Leagues from October to November 2021, as confirmed by the CUT 2021 Annual Report. The report confirms participation only and does not publish CUT team positions, match results, scorecards or player statistics; none are asserted. Source: https://cms.cut.ac.za/Files/Froala/70c49386-3bd3-416b-8683-ba6f29bd7f4d.pdf',
  'completed'
)
on conflict (id) do update set
  name = excluded.name,
  season = excluded.season,
  start_date = excluded.start_date,
  end_date = excluded.end_date,
  venue = excluded.venue,
  description = excluded.description,
  status = excluded.status;
