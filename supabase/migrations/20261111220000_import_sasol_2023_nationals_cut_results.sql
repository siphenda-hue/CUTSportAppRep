-- Create the distinct 2023 Sasol League National Championship record and import CUT Ixias' verified Group C results.
-- Results cross-checked against RSSSF and contemporary Sasol reporting.
insert into public.competitions (sport_id,name,season,start_date,end_date,venue,description,status)
select (select sport_id from public.competitions where name='Sasol Women''s League — Free State' and season='2023' limit 1),
       'SAFA Sasol League National Championship','2023','2023-10-16','2023-10-22',
       'Dr Petrus Molemela Stadium, Bloemfontein',
       'National championship; CUT Ixias qualified as Free State provincial champions and competed in Group C.',
       'completed'
where not exists (select 1 from public.competitions where name='SAFA Sasol League National Championship' and season='2023');

insert into public.competition_matches
(competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,group_name,venue,source_url,source_checked_at,statistics)
select c.id,'sasol-nationals-2023-groupc-ramatlaohle-ixias-20231018','2023-10-18 15:30:00+02','Ramatlaohle Ladies FC','Ixias FC',1,1,'completed','Group C — Matchday 2','Group C','Dr Petrus Molemela Stadium, Bloemfontein','https://rsssf.org/tablesz/zaf-wom2023.html',now(),jsonb_build_object('match_date','2023-10-18')
from public.competitions c where c.name='SAFA Sasol League National Championship' and c.season='2023'
on conflict (competition_id,source_match_id) do update set
starts_at=excluded.starts_at,home_team=excluded.home_team,away_team=excluded.away_team,home_score=excluded.home_score,away_score=excluded.away_score,match_status=excluded.match_status,match_round=excluded.match_round,group_name=excluded.group_name,venue=excluded.venue,source_url=excluded.source_url,source_checked_at=excluded.source_checked_at,statistics=excluded.statistics,updated_at=now();

insert into public.competition_matches
(competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,group_name,venue,source_url,source_checked_at,statistics)
select c.id,'sasol-nationals-2023-groupc-ixias-uct-20231019','2023-10-19 12:30:00+02','Ixias FC','University of Cape Town',0,3,'completed','Group C — Matchday 3','Group C','Dr Petrus Molemela Stadium, Bloemfontein','https://sasolinsport.co.za/teams-secure-their-spots-in-the-semi-finals-as-day-3-of-the-sasol-league-championship-continues/',now(),jsonb_build_object('match_date','2023-10-19')
from public.competitions c where c.name='SAFA Sasol League National Championship' and c.season='2023'
on conflict (competition_id,source_match_id) do update set
starts_at=excluded.starts_at,home_team=excluded.home_team,away_team=excluded.away_team,home_score=excluded.home_score,away_score=excluded.away_score,match_status=excluded.match_status,match_round=excluded.match_round,group_name=excluded.group_name,venue=excluded.venue,source_url=excluded.source_url,source_checked_at=excluded.source_checked_at,statistics=excluded.statistics,updated_at=now();
