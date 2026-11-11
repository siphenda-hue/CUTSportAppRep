-- Preserve similarly named CUT Varsity Cup players as separate records until identity is proven.
-- This is annotation only: no player rows are merged, renamed, or deleted.
update public.competition_player_statistics p
set statistics = p.statistics || jsonb_build_object(
 'identity_resolution_status','unresolved_keep_separate',
 'identity_resolution_note','Similar surname or spelling is not sufficient proof of identity. Keep this record separate until an official squad list, player profile, jersey number, or other reliable source confirms whether the players are the same person.'
),
source_checked_at=now(),updated_at=now()
from public.competitions c
where c.id=p.competition_id
and c.name ilike '%Varsity Cup%'
and extract(year from c.start_date) between 2021 and 2026
and p.team_name ilike '%CUT%'
and (
 lower(p.player_name) like '%cloete%'
 or lower(p.player_name) like '%bessenger%'
);
