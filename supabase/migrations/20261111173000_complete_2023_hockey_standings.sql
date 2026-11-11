-- Complete the missing 2023 CUT men's hockey pool and final standings from SAHA.
with c as (
 select id from public.competitions
 where sport_id=(select id from public.sports where slug='hockey')
 and name='USSA Men C-Section' and season='2023'
), rows(group_name,position,team_name,played,won,drawn,lost,scored,conceded,points) as (
 values
 ('Pool A',1,'Central University of Technology',6,5,0,1,17,6,15),
 ('Pool A',2,'Durban University of Technology',6,4,1,1,31,8,13),
 ('Pool A',3,'Mangosuthu University of Technology',6,3,3,0,13,6,12),
 ('Pool A',4,'University of Limpopo',6,3,1,2,6,8,10),
 ('Pool A',5,'Namibia University of Science and Technology',6,2,1,3,18,14,7),
 ('Pool A',6,'NWU Mafikeng',6,0,1,5,4,17,1),
 ('Pool A',7,'University of Zululand',6,0,1,5,1,31,1),
 ('Final Standing',1,'Central University of Technology',0,0,0,0,0,0,0),
 ('Final Standing',2,'Durban University of Technology',0,0,0,0,0,0,0),
 ('Final Standing',3,'Mangosuthu University of Technology',0,0,0,0,0,0,0),
 ('Final Standing',4,'University of Limpopo',0,0,0,0,0,0,0),
 ('Final Standing',5,'Namibia University of Science and Technology',0,0,0,0,0,0,0),
 ('Final Standing',6,'NWU Mafikeng',0,0,0,0,0,0,0),
 ('Final Standing',7,'University of Zululand',0,0,0,0,0,0,0)
)
insert into public.competition_standings
 (competition_id,group_name,position,team_name,played,won,drawn,lost,scored,conceded,points_difference,bonus_points,points,source_url,source_checked_at)
select c.id,r.group_name,r.position,r.team_name,r.played,r.won,r.drawn,r.lost,r.scored,r.conceded,
 r.scored-r.conceded,0,r.points,
 case when r.group_name='Pool A' then 'https://saha.altiusrt.com/competitions/155/reports/poolstandings'
 else 'https://saha.altiusrt.com/competitions/155/reports/matches' end,now()
from c cross join rows r
on conflict (competition_id,team_name,group_name) do update set
 position=excluded.position,played=excluded.played,won=excluded.won,drawn=excluded.drawn,lost=excluded.lost,
 scored=excluded.scored,conceded=excluded.conceded,points_difference=excluded.points_difference,
 points=excluded.points,source_url=excluded.source_url,source_checked_at=now();
