-- Import CUT Cheerleading's verified 2025 SAMCA National Championships results.
-- CUT's official Sport Achievements page reports these three category placings.
with sport as (
  select id from public.sports where name = 'Cheerleading' limit 1
),
competition as (
  insert into public.competitions
    (sport_id, name, season, start_date, end_date, venue, description, status)
  select sport.id, 'SAMCA National Championships', '2025',
         date '2025-07-04', date '2025-07-12',
         'Oudtshoorn Recreational Grounds, Oudtshoorn, South Africa',
         'CUT Cheerleading achieved 1st place in CoEd Level, 2nd place in All-Girls Level 5, and 2nd place in Pom Doubles at the 2025 South African Majorette and Cheerleading Association National Championships.',
         'completed'
  from sport
  where not exists (
    select 1 from public.competitions c
    where c.sport_id = sport.id
      and c.name = 'SAMCA National Championships'
      and c.season = '2025'
  )
  returning id
),
selected as (
  select id from competition
  union
  select c.id
  from public.competitions c
  join sport on sport.id = c.sport_id
  where c.name = 'SAMCA National Championships' and c.season = '2025'
),
placements as (
  select 'CoEd Level'::text as group_name, 1 as position
  union all select 'All-Girls Level 5', 2
  union all select 'Pom Doubles', 2
)
insert into public.competition_standings
  (competition_id, team_name, group_name, position, source_url, source_checked_at)
select selected.id, 'CUT Cheerleading', placements.group_name, placements.position,
       'https://www.cut.ac.za/sport-achievements', now()
from selected cross join placements
on conflict (competition_id, team_name, group_name)
do update set position = excluded.position,
              source_url = excluded.source_url,
              source_checked_at = excluded.source_checked_at,
              updated_at = now();