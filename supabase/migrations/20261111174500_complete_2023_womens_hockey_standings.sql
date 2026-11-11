-- Complete 2023 CUT women's hockey pool standings from SAHA.
with c as (
 select id from public.competitions
 where sport_id=(select id from public.sports where slug='hockey')
 and name='USSA Women C-Section' and season='2023'
), rows(position,team_name,played,won,drawn,lost,scored,conceded,points) as (
 values
 (1,'Central University of Technology',3,2,1,0,9,3,7),
 (2,'Sol Plaajie University',3,2,1,0,8,2,7),
 (3,'Vaal University of Technology',3,1,0,2,1,7,3),
 (4,'University of Limpopo',3,0,0,3,1,7,0)
)
insert into public.competition_standings
 (competition_id,group_name,position,team_name,played,won,drawn,lost,scored,conceded,points_difference,bonus_points,points,source_url,source_checked_at)
select c.id,'Pool A',r.position,r.team_name,r.played,r.won,r.drawn,r.lost,r.scored,r.conceded,
 r.scored-r.conceded,0,r.points,'https://saha.altiusrt.com/competitions/156/reports/poolstandings',now()
from c cross join rows r
on conflict (competition_id,team_name,group_name) do update set
 position=excluded.position,played=excluded.played,won=excluded.won,drawn=excluded.drawn,lost=excluded.lost,
 scored=excluded.scored,conceded=excluded.conceded,points_difference=excluded.points_difference,
 points=excluded.points,source_url=excluded.source_url,source_checked_at=now();
