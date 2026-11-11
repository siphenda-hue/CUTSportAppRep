-- Import CUT Welkom Campus's verified 2015 Varsity Pro-20 Student Cricket Tournament title.
-- Source: CUT institutional publication, which records the Welkom Campus Cricket Club
-- as the 2015 tournament winner:
-- https://cms.cut.ac.za/Files/Froala/c0aea0d8-303b-44b9-a730-c647fed29d0d.pdf
--
-- No match schedule, scorecards, opponent list or individual statistics are
-- asserted because these details are not present in the available source.

insert into public.competitions (
  id, sport_id, name, season, start_date, end_date, venue, description, status
) values (
  'a43e3a9b-7c4e-4d7e-9f7c-2015c5a00002',
  '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
  'Varsity Pro-20 Student Cricket Tournament',
  '2015',
  '2015-01-01',
  '2015-12-31',
  'CUT Welkom Campus, Welkom, Free State, South Africa',
  'CUT Welkom Campus Cricket Club were the winners of the Varsity Pro-20 Student Cricket Tournament in 2015, as recorded in a CUT institutional publication. The available source does not provide the match schedule, scorecards, opponent list or individual statistics. Source: https://cms.cut.ac.za/Files/Froala/c0aea0d8-303b-44b9-a730-c647fed29d0d.pdf',
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
