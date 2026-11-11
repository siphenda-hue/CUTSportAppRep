
-- Refresh 2026 SAHA match identifiers to the official AltiusRT match IDs.
update public.competition_matches m
set source_match_id=v.match_id,
    source_url='https://saha.altiusrt.com/matches/'||v.match_id,
    source_checked_at=now()
from public.competitions c
join (values
 ('USSA Men B-Section','2026','TUT-CUT','7600'),
 ('USSA Men B-Section','2026','UWC-CUT','7601'),
 ('USSA Men B-Section','2026','CUT-UKZN','7608'),
 ('USSA Men B-Section','2026','EME-CUT','7611'),
 ('USSA Men B-Section','2026','CUT-ETA','7612'),
 ('USSA Women B-Section','2026','UWC-CUT','7613'),
 ('USSA Women B-Section','2026','CUT-NUST','7620'),
 ('USSA Women B-Section','2026','CUT-RHODES','7621'),
 ('USSA Women B-Section','2026','VUT-CUT','7626'),
 ('USSA Women B-Section','2026','TUT-CUT','7628')
) v(name,season,old_id,match_id) on true
where m.competition_id=c.id and c.name=v.name and c.season=v.season and m.source_match_id=v.old_id;

-- Correct the official women's B-Section final ranking, keeping pool standings separate.
update public.competition_standings s
set position=v.position,source_url='https://saha.altiusrt.com/competitions/265/matches',source_checked_at=now()
from public.competitions c
join (values
 ('University of the Western Cape',1),
 ('University of the Free State',2),
 ('Rhodes University',3),
 ('ETA College',4),
 ('Tshwane University of Technology',5),
 ('Central University of Technology',6),
 ('Namibia University of Science and Technology',7),
 ('Vaal University of Technology',8)
) v(team_name,position) on true
where s.competition_id=c.id and c.name='USSA Women B-Section' and c.season='2026'
and s.group_name='Final Standing' and s.team_name=v.team_name;

update public.competition_standings s
set scored=v.scored,conceded=v.conceded,points_difference=v.scored-v.conceded,source_checked_at=now()
from public.competitions c
join (values
 ('USSA Men B-Section','2026','Pool A','EMERIS',41,5),
 ('USSA Men B-Section','2026','Pool A','ETA College',29,12),
 ('USSA Men B-Section','2026','Pool A','University of Kwa-Zulu Natal',12,13),
 ('USSA Men B-Section','2026','Pool A','University of the Western Cape',8,12),
 ('USSA Men B-Section','2026','Pool A','Tshwane University of Technology',4,18),
 ('USSA Men B-Section','2026','Pool A','Central University of Technology',7,41),
 ('USSA Women B-Section','2026','Pool A','University of the Free State',25,0),
 ('USSA Women B-Section','2026','Pool A','ETA College',6,6),
 ('USSA Women B-Section','2026','Pool A','Tshwane University of Technology',3,10),
 ('USSA Women B-Section','2026','Pool A','Vaal University of Technology',0,18),
 ('USSA Women B-Section','2026','Pool B','University of the Western Cape',24,0),
 ('USSA Women B-Section','2026','Pool B','Rhodes University',6,6),
 ('USSA Women B-Section','2026','Pool B','Central University of Technology',12,8),
 ('USSA Women B-Section','2026','Pool B','Namibia University of Science and Technology',0,28)
) v(name,season,grp,team_name,scored,conceded) on true
where s.competition_id=c.id and c.name=v.name and c.season=v.season and s.group_name=v.grp and s.team_name=v.team_name;

delete from public.competition_player_statistics p
using public.competitions c
where p.competition_id=c.id and c.name='USSA Women B-Section' and c.season='2026'
and p.team_name='Central University of Technology' and p.player_name='HOOGENDOORN Elisha';
