-- Import 2022 Free State Sasol Women's League tables for both CUT-linked streams.
-- Source: RSSSF South Africa (Women) 2022.
insert into public.competition_standings
(competition_id,team_name,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,bonus_points,points,source_url,source_checked_at)
values
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','Central University of Technology FC','Stream A',1,12,11,0,1,54,7,47,0,33,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','Grassland Ladies FC','Stream A',2,12,7,2,3,26,13,13,0,23,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','Black Urban FC','Stream A',3,12,5,4,3,18,16,2,0,19,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','De Jaguars FC','Stream A',4,12,5,3,4,24,28,-4,0,18,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','UGU FC','Stream A',5,12,5,0,7,20,23,-3,0,15,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','Inter Madrid Ladies Academy FC','Stream A',6,12,2,2,8,11,33,-22,0,8,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','Clever Girls FC','Stream A',7,12,2,1,9,16,49,-33,0,7,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','Young Once FC','Stream A',null,0,0,0,0,0,0,0,0,0,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','IXIAS FC (CUT Welkom)','Stream B',1,10,9,1,0,78,5,73,0,28,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','Kovsies FC','Stream B',2,10,8,0,2,90,7,83,0,24,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','Metheo Ladies FC','Stream B',3,10,5,1,4,32,11,21,0,16,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','TTKAY FC','Stream B',4,10,3,0,7,14,30,-16,0,9,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','Dikonyela FC','Stream B',5,10,2,0,8,9,85,-76,0,6,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','Phumelela Warriors FC','Stream B',6,10,2,0,8,10,95,-85,0,6,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','Ace Milan FC','Stream B',null,0,0,0,0,0,0,0,0,0,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','Kolisang Ladies FC','Stream B',null,0,0,0,0,0,0,0,0,0,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now()),
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','Metsimaholo FC','Stream B',null,0,0,0,0,0,0,0,0,0,'https://www.rsssf.org/tablesz/zaf-wom2022.html',now())
on conflict (competition_id,team_name,group_name) do update set
position=excluded.position,played=excluded.played,won=excluded.won,drawn=excluded.drawn,lost=excluded.lost,
scored=excluded.scored,conceded=excluded.conceded,points_difference=excluded.points_difference,
bonus_points=excluded.bonus_points,points=excluded.points,source_url=excluded.source_url,source_checked_at=excluded.source_checked_at;
