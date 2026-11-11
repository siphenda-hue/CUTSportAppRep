-- Extend verified CUT football and netball competition records.
-- Sources are retained on each imported row. Unknown player-level statistics are not fabricated.

-- Free State Sasol Women's League standings: CUT Ixias Ladies.
insert into public.competition_standings
(competition_id,team_name,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,bonus_points,points,source_url,source_checked_at)
select c.id,v.team_name,v.grp,v.pos,v.pld,v.w,v.d,v.l,v.gf,v.ga,v.gd,0,v.pts,v.src,now()
from (values
('2024','Ixias Ladies','Free State Group 1A',1,14,13,1,0,83,1,82,40,'https://rsssf.org/tablesz/zaf-wom2024.html'),
('2024','Metsimaholo Ladies FC','Free State Group 1A',2,14,10,2,2,47,9,38,32,'https://rsssf.org/tablesz/zaf-wom2024.html'),
('2024','Inter Madrid Academy','Free State Group 1A',3,14,7,4,3,34,13,21,25,'https://rsssf.org/tablesz/zaf-wom2024.html'),
('2024','Grassland Ladies','Free State Group 1A',4,14,5,4,5,29,22,7,19,'https://rsssf.org/tablesz/zaf-wom2024.html'),
('2024','Peace Lovers FC','Free State Group 1A',5,14,5,4,5,24,23,1,19,'https://rsssf.org/tablesz/zaf-wom2024.html'),
('2024','Napoli Ladies FC','Free State Group 1A',6,14,3,4,7,35,40,-5,13,'https://rsssf.org/tablesz/zaf-wom2024.html'),
('2024','Queens FC','Free State Group 1A',7,14,3,1,10,16,36,-20,10,'https://rsssf.org/tablesz/zaf-wom2024.html'),
('2024','FC Kerlis','Free State Group 1A',8,14,0,0,14,3,127,-124,0,'https://rsssf.org/tablesz/zaf-wom2024.html'),
('2023','Ixias Ladies','Free State Stream A',1,12,12,0,0,79,4,75,36,'https://en.wikipedia.org/wiki/2023_Sasol_Women%27s_League'),
('2023','Central University of FS','Free State Stream A',2,12,10,0,2,79,5,74,30,'https://en.wikipedia.org/wiki/2023_Sasol_Women%27s_League'),
('2023','Inter Madrid Academy','Free State Stream A',3,12,5,3,4,20,19,1,18,'https://en.wikipedia.org/wiki/2023_Sasol_Women%27s_League'),
('2023','TTKay FC','Free State Stream A',4,12,5,2,5,22,26,-4,17,'https://en.wikipedia.org/wiki/2023_Sasol_Women%27s_League'),
('2023','De Jaguar FC','Free State Stream A',5,12,4,1,7,21,33,-12,13,'https://en.wikipedia.org/wiki/2023_Sasol_Women%27s_League'),
('2023','Matsimaholo Ladies','Free State Stream A',6,12,3,0,9,14,62,-48,9,'https://en.wikipedia.org/wiki/2023_Sasol_Women%27s_League'),
('2023','Black Urban FC','Free State Stream A',7,0,0,0,0,0,0,0,'https://en.wikipedia.org/wiki/2023_Sasol_Women%27s_League'),
('2023','Molefe Khalinkomo FC','Free State Stream A',8,12,0,0,12,4,80,-76,0,'https://en.wikipedia.org/wiki/2023_Sasol_Women%27s_League')
) as v(season,team_name,grp,pos,pld,w,d,l,gf,ga,gd,pts,src)
join public.competitions c on c.name='Sasol Women''s League — Free State' and c.season=v.season
where not exists (
 select 1 from public.competition_standings s
 where s.competition_id=c.id and s.team_name=v.team_name and s.group_name=v.grp
);

-- Remove the older duplicate 2024 CUT line; the complete Group 1A table above is canonical.
delete from public.competition_standings s
using public.competitions c
where s.competition_id=c.id and c.name='Sasol Women''s League — Free State' and c.season='2024'
and s.team_name='Ixias FC (CUT)' and s.group_name='Stream A'
and exists (select 1 from public.competition_standings x where x.competition_id=c.id and x.team_name='Ixias Ladies' and x.group_name='Free State Group 1A');

-- Goal totals are season totals from the corresponding league records.
update public.competition_team_statistics t
set total_goals = case
 when c.season='2023' and c.name='Sasol Women''s League — Free State' then 79
 when c.season='2024' and c.name='Sasol Women''s League — Free State' then 83
 when c.season='2025' and c.name='SAFA Sasol League National Championship' then 4
 else t.total_goals end,
source_url = case
 when c.season='2023' and c.name='Sasol Women''s League — Free State' then 'https://en.wikipedia.org/wiki/2023_Sasol_Women%27s_League'
 when c.season='2024' and c.name='Sasol Women''s League — Free State' then 'https://rsssf.org/tablesz/zaf-wom2024.html'
 when c.season='2025' and c.name='SAFA Sasol League National Championship' then 'https://en.wikipedia.org/wiki/2025_Sasol_League_National_Championship'
 else t.source_url end,
source_checked_at=now()
from public.competitions c
where t.competition_id=c.id and (
 (c.name='Sasol Women''s League — Free State' and c.season in ('2023','2024') and t.team_name ilike '%Ixias%')
 or (c.name='SAFA Sasol League National Championship' and c.season='2025' and t.team_name ilike '%Ixias%')
);

-- Varsity Netball 2026: CUT finished seventh, with one win and six losses.
insert into public.competition_standings
(competition_id,team_name,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,bonus_points,points,source_url,source_checked_at)
select c.id,'CUT','Final Log',7,7,1,0,6,298,372,-74,0,6,
'https://novanews.co.za/bloemnewsexpress/powerhouses-reach-varsity-netball-semis-uj-chase-maiden-title/',now()
from public.competitions c
where c.name='Varsity Netball' and c.season='2026'
and not exists (select 1 from public.competition_standings s where s.competition_id=c.id and s.team_name='CUT' and s.group_name='Final Log');

update public.competition_standings s
set position=7,played=7,won=1,drawn=0,lost=6,scored=298,conceded=372,points_difference=-74,bonus_points=0,points=6,
source_url='https://novanews.co.za/bloemnewsexpress/powerhouses-reach-varsity-netball-semis-uj-chase-maiden-title/',source_checked_at=now()
from public.competitions c
where s.competition_id=c.id and c.name='Varsity Netball' and c.season='2026'
and s.team_name='CUT' and s.group_name='Final Log';

delete from public.competition_standings s
using public.competitions c
where s.competition_id=c.id and c.name='Varsity Netball' and c.season='2026'
and s.team_name='CUT' and s.group_name='CUT Team Summary'
and exists (select 1 from public.competition_standings x where x.competition_id=c.id and x.team_name='CUT' and x.group_name='Final Log');

update public.competition_team_statistics t
set total_goals=298,
source_url='https://novanews.co.za/bloemnewsexpress/powerhouses-reach-varsity-netball-semis-uj-chase-maiden-title/',
source_checked_at=now()
from public.competitions c
where t.competition_id=c.id and c.name='Varsity Netball' and c.season='2026' and t.team_name='CUT';

-- Official summaries record CUT's USSA Netball overall finishes.
update public.competitions
set description = case
 when season='2025' and name='USSA Netball Championships' then 'CUT finished 8th overall in the 2025 USSA National Netball Tournament, qualifying for Varsity Netball 2026. Source: https://www.cut.ac.za/news/cut-netball-team-qualifies-for-varsity-netball-2026'
 when season='2026' and name='USSA Netball Championships' then 'CUT finished 5th overall at the 2026 USSA Netball Championships hosted at CUT Bloemfontein. Source: https://supersport.com/netball/news/9da6e7fa-9944-4137-9225-eca053b1a390/double-delight-for-the-orange-army-as-they-rule-ussa-netball-once-again'
 else description end
where name='USSA Netball Championships' and season in ('2025','2026');

-- CUT's 2026 Varsity Cup campaign: four log points including bonus points.
update public.competition_standings s
set bonus_points=4,points=4,
source_url='https://en.wikipedia.org/wiki/2026_Varsity_Cup',source_checked_at=now()
from public.competitions c
where s.competition_id=c.id and c.name='FNB Varsity Cup' and c.season='2026' and s.team_name='CUT Ixias';
