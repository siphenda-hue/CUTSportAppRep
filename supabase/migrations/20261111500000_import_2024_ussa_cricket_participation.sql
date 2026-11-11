-- Record CUT's verified participation in the 2024 USSA Cricket A Section.
-- Source evidence: UJ reports CUT lost to UJ by 106 runs; Maties reports a
-- group-stage win against CUT. No final CUT placing or complete scorecards
-- are asserted because the available reports do not establish them.

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
  '646179dd-9582-47f9-97f1-9fd577068726',
  '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
  'USSA Cricket Tournament',
  '2024',
  '2024-12-02',
  '2024-12-06',
  'Bloemfontein, Free State, South Africa (University of the Free State and Central University of Technology venues)',
  'CUT participated in the 2024 USSA Cricket A Section tournament hosted in Bloemfontein from 2–6 December 2024. Confirmed published results include a group-stage defeat to Stellenbosch University (Maties) and a defeat to the University of Johannesburg by 106 runs. The available reports do not establish CUT’s final tournament placing or complete match scorecards; no other results or player statistics are asserted.',
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
