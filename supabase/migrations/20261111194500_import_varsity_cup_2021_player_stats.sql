-- Add verified CUT player scoring milestones from the 2021 Varsity Cup.
update public.competition_player_statistics p
set statistics=coalesce(p.statistics,'{}'::jsonb)||'{"tries":7}'::jsonb,
source_url='https://www.varsitycup.co.za/news/preview-2021-fnb-varsity-cup-semi-finals',
source_checked_at=now()
from public.competitions c
where p.competition_id=c.id and c.name='FNB Varsity Cup' and c.season='2021'
and p.player_name='Cohen Jasper' and p.team_name='CUT Ixias';

update public.competition_player_statistics p
set statistics=coalesce(p.statistics,'{}'::jsonb)||'{"points":60,"tries":12,"top_try_scorer":true}'::jsonb,
source_url='https://www.varsitycup.co.za/news/preview-2021-fnb-varsity-cup-semi-finals',
source_checked_at=now()
from public.competitions c
where p.competition_id=c.id and c.name='FNB Varsity Cup' and c.season='2021'
and p.player_name='Janus Venter' and p.team_name='CUT Ixias';

insert into public.competition_player_statistics
(competition_id,player_name,team_name,field_goals,penalty_corner_goals,penalty_stroke_goals,total_goals,statistics,source_url,source_checked_at)
select c.id,'Charles Williams','CUT Ixias',0,0,0,0,
'{"points":71,"top_points_scorer_rank":4}'::jsonb,
'https://www.varsitycup.co.za/news/preview-2021-fnb-varsity-cup-semi-finals',now()
from public.competitions c
where c.name='FNB Varsity Cup' and c.season='2021'
and not exists(select 1 from public.competition_player_statistics p where p.competition_id=c.id and p.player_name='Charles Williams' and p.team_name='CUT Ixias');
