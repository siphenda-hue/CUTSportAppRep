update public.competition_player_statistics cps
set total_goals = coalesce(
  nullif(cps.statistics->>'total_tries', '')::integer,
  nullif(cps.statistics->>'tries', '')::integer,
  cps.total_goals
)
from public.competitions c
where c.id = cps.competition_id
  and c.name ilike '%Varsity Cup%'
  and c.season between '2021' and '2026'
  and cps.team_name ilike '%CUT%'
  and cps.total_goals = 0
  and (
    coalesce(nullif(cps.statistics->>'total_tries', '')::integer, 0) > 0
    or coalesce(nullif(cps.statistics->>'tries', '')::integer, 0) > 0
  );