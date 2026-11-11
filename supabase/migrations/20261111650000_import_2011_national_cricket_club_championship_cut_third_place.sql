-- Import CUT Cricket's verified 2011 National Cricket Club Championship finish.
-- CUT's institutional five-year achievements summary confirms third place.
-- Venue, dates, match results, scorecards and player statistics are not
-- provided in the accessible source and are intentionally left unspecified.

insert into public.competitions
  (id, sport_id, name, season, start_date, end_date, venue, description, status)
values (
  'a43e3a9b-7c4e-4d7e-9f7c-2011c5a00001'::uuid,
  '481726ef-be80-4f8e-a0c4-c5f8c41a0f74'::uuid,
  'National Cricket Club Championship',
  '2011',
  null,
  null,
  null,
  'CUT Cricket achieved third position in the National Cricket Club Championship in 2011. CUT''s institutional report also records the club as Free State Super League champions in 2010 and 2011. The accessible institutional source does not provide the National Club Championship venue, dates, match results, scorecards or individual player statistics; none are asserted.',
  'completed'
)
on conflict (id) do nothing;
