-- Verified CUT USSA Volleyball season placements (2024-2025).
-- Only final positions are published in the available CUT source; match records,
-- set scores, gender-specific placings and season statistics are intentionally omitted.
with sport as (
  select id from public.sports where name = 'Volleyball' limit 1
),
season_rows as (
  select '2024'::text as season,
         'USSA Volleyball Championships'::text as name,
         null::date as start_date, null::date as end_date,
         null::text as venue,
         'CUT Volleyball Club finished 7th overall. Detailed match results, set scores and gender-specific standings were not verified from an accessible primary source.'::text as description
  union all
  select '2025', 'USSA Volleyball Championships',
         date '2025-06-29', date '2025-07-03', 'Cape Town, South Africa',
         'Hosted by the University of Cape Town, 29 June–3 July 2025. CUT Volleyball Club finished 7th overall. Detailed match results, set scores and gender-specific standings were not verified from an accessible primary source.'
),
inserted as (
  insert into public.competitions
    (sport_id, name, season, start_date, end_date, venue, description, status)
  select sport.id, s.name, s.season, s.start_date, s.end_date, s.venue, s.description, 'completed'
  from sport cross join season_rows s
  where not exists (
    select 1 from public.competitions c
    where c.sport_id = sport.id and c.name = s.name and c.season = s.season
  )
  returning id, season
),
competition_ids as (
  select c.id, c.season
  from public.competitions c
  join sport on sport.id = c.sport_id
  where c.name = 'USSA Volleyball Championships' and c.season in ('2024','2025')
),
all_ids as (
  select id, season from inserted
  union
  select id, season from competition_ids
)
insert into public.competition_standings
  (competition_id, team_name, group_name, position, source_url, source_checked_at)
select id, 'CUT Volleyball Club', 'Overall', 7,
       'https://www.cut.ac.za/sport-achievements', now()
from all_ids
on conflict (competition_id, team_name, group_name)
do update set position = excluded.position,
              source_url = excluded.source_url,
              source_checked_at = excluded.source_checked_at,
              updated_at = now();