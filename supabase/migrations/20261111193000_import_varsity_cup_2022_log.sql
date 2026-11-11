-- Verified final 2022 FNB Varsity Cup log.
-- CUT Ixias finished 10th after 9 matches; they remained in the top tier for 2023.
insert into public.competition_standings
(competition_id,team_name,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,bonus_points,points,source_url,source_checked_at)
select c.id,v.team_name,'Final Log',v.pos,v.pld,v.w,v.d,v.l,v.pf,v.pa,v.pd,v.bp,v.pts,'https://en.wikipedia.org/wiki/2022_Varsity_Cup',now()
from public.competitions c
cross join (values
('UFS Shimlas',1,9,7,0,2,400,228,172,9,37),
('UCT Ikey Tigers',2,9,7,0,2,307,270,37,8,36),
('Maties',3,9,7,0,2,324,232,92,6,34),
('UP Tuks',4,9,6,0,3,279,172,107,6,30),
('NWU Eagles',5,9,6,0,3,266,182,84,5,29),
('UJ',6,9,4,1,4,287,258,29,6,24),
('Wits',7,9,4,0,5,239,262,-25,4,20),
('UWC',8,9,2,0,7,255,403,-148,5,13),
('NMU Madibaz',9,9,1,0,8,194,389,-195,5,9),
('CUT Ixias',10,9,0,1,8,219,372,-153,6,8)
) as v(team_name,pos,pld,w,d,l,pf,pa,pd,bp,pts)
where c.name='FNB Varsity Cup' and c.season='2022'
and not exists(select 1 from public.competition_standings s where s.competition_id=c.id and s.team_name=v.team_name and s.group_name='Final Log');
