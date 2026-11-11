-- 2023 Sasol League National Championship Group C final table (RSSSF).
insert into public.competition_standings
(competition_id,team_name,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,bonus_points,points,source_url,source_checked_at)
select c.id,v.team_name,'Group C',v.position,v.played,v.won,v.drawn,v.lost,v.scored,v.conceded,v.gd,0,v.points,
       'https://rsssf.org/tablesz/zaf-wom2023.html',now()
from public.competitions c
cross join (values
('Ramatlaohle Ladies FC',1,2,1,1,0,4,2,2,4),
('University of Cape Town',2,2,1,0,1,4,3,1,3),
('Ixias FC',3,2,0,1,1,1,4,-3,1)
) as v(team_name,position,played,won,drawn,lost,scored,conceded,gd,points)
where c.name='SAFA Sasol League National Championship' and c.season='2023'
on conflict (competition_id,team_name,group_name) do update set
position=excluded.position,played=excluded.played,won=excluded.won,drawn=excluded.drawn,lost=excluded.lost,
scored=excluded.scored,conceded=excluded.conceded,points_difference=excluded.points_difference,
points=excluded.points,source_url=excluded.source_url,source_checked_at=excluded.source_checked_at,updated_at=now();
