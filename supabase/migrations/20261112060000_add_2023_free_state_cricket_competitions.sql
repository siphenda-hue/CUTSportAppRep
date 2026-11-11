-- Record the two distinct Free State cricket competitions evidenced by the CUT 2023 Annual Report.
-- Participation is documented; no unreported standings, scores, fixtures or player statistics are fabricated.
insert into public.competitions (id, sport_id, name, season, description)
values
  (
    'a43e3a9b-7c4e-4d7e-9f7c-2023f5a00001',
    '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
    'Free State Cricket League',
    '2023',
    'CUT Cricket participation in the Free State Cricket League during the 2023 reporting year is confirmed by the CUT 2023 Annual Report. The report does not publish CUT team positions, fixtures, match results, scorecards or player statistics; none are asserted. Source: https://cms.cut.ac.za/Files/Froala/dce12fb4-9f02-488d-b89a-685cce45d2e6.pdf'
  ),
  (
    'a43e3a9b-7c4e-4d7e-9f7c-2023f5a00002',
    '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
    'Free State Cricket Union League – First Round',
    '2023',
    'CUT men’s and women’s cricket teams participated in the first round of the Free State Cricket Union League during the 2023 reporting year, as confirmed by the CUT 2023 Annual Report. The report does not publish team positions, fixtures, match results, scorecards or player statistics; none are asserted. Source: https://cms.cut.ac.za/Files/Froala/dce12fb4-9f02-488d-b89a-685cce45d2e6.pdf'
  )
on conflict (id) do nothing;
