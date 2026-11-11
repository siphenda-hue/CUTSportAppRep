-- Make the coverage limits explicit across the 2021-2026 CUT Varsity Cup player records.
-- None of these player tables should be interpreted as a complete squad-wide season leaderboard.
update public.competition_player_statistics p
set statistics = p.statistics || jsonb_build_object(
 'season_total_complete',false,
 'stat_scope',case
  when extract(year from c.start_date)=2021 then 'official tournament leaderboard highlights; only listed top performers stored'
  when extract(year from c.start_date)=2022 then 'verified individual try scorers in seven available match reports; incomplete season coverage'
  else 'verified individual try scorers in available match reports; full-season completeness not established'
 end
),
source_checked_at=now(),updated_at=now()
from public.competitions c
where c.id=p.competition_id
and c.name ilike '%Varsity Cup%'
and extract(year from c.start_date) between 2021 and 2026
and p.team_name ilike '%CUT%';