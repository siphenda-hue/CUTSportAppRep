-- Import verified CUT men's provincial Football history for 2021/22 and 2022.
-- Structured standings are limited to placings explicitly reported by CUT.

with abc as (
  insert into public.competitions
    (id, sport_id, name, season, venue, description, status)
  values
    ('a43e3a9b-7c4e-4d7e-9f7c-2021a5a00001'::uuid,
     '4c1ccd6f-3965-422a-ad25-19aaa2797f23'::uuid,
     'ABC Motsepe League — Free State',
     '2021/22',
     null,
     'CUT Football completed the 2021/22 ABC Motsepe League season in 6th position in Stream B and 12th on the overall Free State provincial standing. The available CUT annual report confirms the two placings but does not provide a complete match schedule or detailed points totals.',
     'completed')
  on conflict (id) do update set
    description = excluded.description,
    status = 'completed'
  returning id
)
insert into public.competition_standings
  (competition_id, team_name, group_name, position, source_url, source_checked_at)
select abc.id, 'CUT Football', x.group_name, x.position,
       'https://cms.cut.ac.za/Files/Froala/a331d2a8-5ca9-493d-85dd-a942791a1a64.pdf',
       now()
from abc
cross join (values ('Stream B', 6), ('Overall Free State', 12)) as x(group_name, position)
on conflict (competition_id, team_name, group_name) do update set
  position = excluded.position,
  source_url = excluded.source_url,
  source_checked_at = now(),
  updated_at = now();

with cup as (
  insert into public.competitions
    (id, sport_id, name, season, start_date, end_date, venue, description, status)
  values
    ('a43e3a9b-7c4e-4d7e-9f7c-2022a5c00001'::uuid,
     '4c1ccd6f-3965-422a-ad25-19aaa2797f23'::uuid,
     'Mangaung Local Football Cup',
     '2022',
     '2022-09-11',
     '2022-09-11',
     null,
     'CUT Football won the Mangaung Local Football Cup on 11 September 2022. The CUT annual report confirms the title but does not provide the final score, opponent or match venue.',
     'completed')
  on conflict (id) do update set
    description = excluded.description,
    start_date = excluded.start_date,
    end_date = excluded.end_date,
    status = 'completed'
  returning id
)
insert into public.competition_standings
  (competition_id, team_name, group_name, position, source_url, source_checked_at)
select cup.id, 'CUT Football', 'Tournament Champion', 1,
       'https://cms.cut.ac.za/Files/Froala/a331d2a8-5ca9-493d-85dd-a942791a1a64.pdf',
       now()
from cup
on conflict (competition_id, team_name, group_name) do update set
  position = 1,
  source_url = excluded.source_url,
  source_checked_at = now(),
  updated_at = now();

-- Distinguish CUT Bloemfontein and CUT Welkom women's teams in the 2022 league
-- and disclose the annual-report narrative versus detailed table discrepancy.
update public.competitions
set description = 'CUT had two distinct women’s teams in the 2022 Free State Sasol League: Central University of Technology FC finished first in Stream A (12 played, 11 wins, 1 loss, 54 goals for, 7 against, 33 points); IXIAS FC (CUT Welkom) finished first in Stream B (10 played, 9 wins, 1 draw, 78 goals for, 5 against, 28 points). The CUT annual report separately states that the ladies’ team won ten matches without defeat and were crowned provincial champions before playing the national promotion play-offs in Polokwane in October 2022. Because the annual report narrative and detailed league table differ on the Stream A win/loss totals, the detailed table values are retained as the structured standings and the discrepancy is disclosed here.'
where id = '6c45083c-ce0c-48e0-be1d-c1eea248bb05';
