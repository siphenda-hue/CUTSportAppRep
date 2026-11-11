-- Record the documented first round of the 2022/23 Mangaung Cricket Association League.
-- Source: CUT Annual Report 2022, section 6.14.5, p. 281.
-- Dates are confirmed; CUT standings, scorecards and player statistics are not published.

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
  'a43e3a9b-7c4e-4d7e-9f7c-2022c5a00002',
  '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
  'Mangaung Cricket Association League – First Round',
  '2022/23',
  '2022-10-08',
  '2022-11-26',
  'Mangaung, Free State, South Africa',
  'The CUT annual report records that the Mangaung Cricket Association Leagues began on 8 October 2022 and the first round concluded on 26 November 2022. This is a separate competition phase from the 2021/22 MCA season, which ended in March 2022 with CUT 1 first and CUT 2 fourth. The report does not publish CUT team standings, match results, scorecards or player statistics for the October–November 2022 first round; none are asserted. Source: https://cms.cut.ac.za/Files/Froala/a331d2a8-5ca9-493d-85dd-a942791a1a64.pdf',
  'completed'
)
on conflict (id) do update
set
  start_date = excluded.start_date,
  end_date = excluded.end_date,
  venue = excluded.venue,
  description = excluded.description,
  status = excluded.status;
