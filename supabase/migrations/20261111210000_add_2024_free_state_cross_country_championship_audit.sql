-- Record the verified 2024 Free State Cross Country Championships event metadata.
-- No individual CUT results are imported: affiliation and exact athlete matches are not established.
insert into public.competitions (id, sport_id, name, season, start_date, description, status)
select 'a43e3a9b-7c4e-4d7e-9f7c-2024f5c00001'::uuid,
       s.id,
       'Free State Cross Country Championships',
       '2024',
       date '2024-08-03',
       'Event date and age-group result sheet identify the Free State Cross Country Championships as held on 3 August 2024. The available results copy is a secondary-hosted transcription of the all-athletes age-group sheet; it is not treated as an official source for CUT affiliation. The sheet lists school/club affiliations and does not identify a CUT team entry. No CUT individual results or team standings have been imported. CUT athlete registry is currently empty, and the CUT-only import rule requires exact matching to an existing CUT athlete record plus independent CUT affiliation confirmation. Venue is not stated in the retrieved result sheet and is intentionally left blank. Source copy: https://www.studocu.com/en-za/document/curro-roodeplaat-high-school/english-home-language-mandatory/2024-fs-cc-champs-results-per-age/101884804 . Official regional results archive: https://www.athleticsfs.co.za/results/cross-country/',
       'completed'
from public.sports s
where s.name='Athletics & Cross Country'
on conflict (id) do update set
 name=excluded.name, season=excluded.season, start_date=excluded.start_date,
 description=excluded.description, status=excluded.status
where public.competitions.name='Free State Cross Country Championships'
  and public.competitions.season='2024';
