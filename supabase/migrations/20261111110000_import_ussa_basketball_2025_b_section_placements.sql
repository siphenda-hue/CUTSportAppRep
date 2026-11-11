-- Import CUT's verified 2025 USSA Basketball B-Section final positions.
-- CUT Annual Report 2025: men fifth; women fourth; Wits host, 1-5 Dec 2025.
with sport as (
  select id from public.sports where name = 'Basketball' limit 1
),
seasons as (
  select 'USSA Men B-Section'::text as name, '2025'::text as season,
         'CUT men finished 5th in the USSA Basketball B-Section tournament hosted by Wits from 1–5 December 2025.'::text as description,
         5 as position
  union all
  select 'USSA Women B-Section', '2025',
         'CUT women finished 4th in the USSA Basketball B-Section tournament hosted by Wits from 1–5 December 2025, narrowly missing promotion after losing the semi-final.',
         4
),
inserted as (
  insert into public.competitions
    (sport_id, name, season, start_date, end_date, venue, description, status)
  select sport.id, s.name, s.season, date '2025-12-01', date '2025-12-05',
         'University of the Witwatersrand, Johannesburg, South Africa',
         s.description, 'completed'
  from sport cross join seasons s
  where not exists (
    select 1 from public.competitions c
    where c.sport_id = sport.id and c.name = s.name and c.season = s.season
  )
  returning id, name
),
all_ids as (
  select id, name from inserted
  union
  select c.id, c.name from public.competitions c
  join sport on sport.id = c.sport_id
  where c.season = '2025' and c.name in ('USSA Men B-Section','USSA Women B-Section')
)
insert into public.competition_standings
  (competition_id, team_name, group_name, position, source_url, source_checked_at)
select a.id, 'Central University of Technology', 'Overall',
       case when a.name = 'USSA Men B-Section' then 5 else 4 end,
       'https://cms.cut.ac.za/Files/Froala/e1338b1b-1a2c-4dd1-8867-270ca64cbf93.pdf',
       now()
from all_ids a
on conflict (competition_id, team_name, group_name)
do update set position = excluded.position,
              source_url = excluded.source_url,
              source_checked_at = excluded.source_checked_at,
              updated_at = now();