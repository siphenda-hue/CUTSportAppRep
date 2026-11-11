alter table public.competition_matches
  add column if not exists statistics jsonb not null default '{}'::jsonb;
alter table public.competition_player_statistics
  add column if not exists statistics jsonb not null default '{}'::jsonb;
alter table public.competition_team_statistics
  add column if not exists statistics jsonb not null default '{}'::jsonb;

update public.competitions
set status='completed',
    description='2026 FNB Varsity Cup men. CUT Ixias finished 8th after seven losses (172 points scored, 391 conceded, -219 points difference, 2 log points). Full league standings and CUT fixtures/results imported from published competition records.'
where id='7461d49d-ebeb-445e-a24f-6bba098968d5';

insert into public.competition_matches
(competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,venue,source_url,statistics)
values
('7461d49d-ebeb-445e-a24f-6bba098968d5','2026-vc-r1-cut-nwu','2026-02-16 17:00:00+02','CUT Ixias','NWU Eagles',42,59,'completed','Round 1','CUT Rugby Stadium','https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/', '{"competition":"FNB Varsity Cup","sport":"Rugby Union"}'),
('7461d49d-ebeb-445e-a24f-6bba098968d5','2026-vc-r2-uct-cut','2026-02-23 17:00:00+02','UCT Ikeys','CUT Ixias',83,34,'completed','Round 2','The Green Mile','https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/', '{"competition":"FNB Varsity Cup","sport":"Rugby Union"}'),
('7461d49d-ebeb-445e-a24f-6bba098968d5','2026-vc-r3-cut-ufs','2026-03-02 17:00:00+02','CUT Ixias','UFS Shimlas',19,71,'completed','Round 3','CUT Rugby Stadium','https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/', '{"competition":"FNB Varsity Cup","sport":"Rugby Union"}'),
('7461d49d-ebeb-445e-a24f-6bba098968d5','2026-vc-r4-tuks-cut','2026-03-09 17:00:00+02','UP Tuks','CUT Ixias',78,17,'completed','Round 4','Tuks Rugby Stadium','https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/', '{"competition":"FNB Varsity Cup","sport":"Rugby Union"}'),
('7461d49d-ebeb-445e-a24f-6bba098968d5','2026-vc-r5-emeris-cut','2026-03-16 17:00:00+02','Emeris','CUT Ixias',26,24,'completed','Round 5','Emeris Durban North','https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/', '{"competition":"FNB Varsity Cup","sport":"Rugby Union"}'),
('7461d49d-ebeb-445e-a24f-6bba098968d5','2026-vc-r6-cut-uj','2026-03-23 17:00:00+02','CUT Ixias','UJ',13,29,'completed','Round 6','CUT Stadium','https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/', '{"competition":"FNB Varsity Cup","sport":"Rugby Union"}'),
('7461d49d-ebeb-445e-a24f-6bba098968d5','2026-vc-r7-cut-maties','2026-03-30 17:00:00+02','CUT Ixias','Maties',23,45,'completed','Round 7','CUT Rugby Stadium','https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/', '{"competition":"FNB Varsity Cup","sport":"Rugby Union"}')
on conflict (competition_id,source_match_id) do update set
 starts_at=excluded.starts_at,home_team=excluded.home_team,away_team=excluded.away_team,
 home_score=excluded.home_score,away_score=excluded.away_score,match_status=excluded.match_status,
 match_round=excluded.match_round,venue=excluded.venue,source_url=excluded.source_url,
 statistics=excluded.statistics,source_checked_at=now(),updated_at=now();

insert into public.competition_standings
(competition_id,team_name,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,bonus_points,points,source_url,source_checked_at)
values
('7461d49d-ebeb-445e-a24f-6bba098968d5','UP Tuks','League Table',1,7,6,0,1,289,154,135,4,28,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/',now()),
('7461d49d-ebeb-445e-a24f-6bba098968d5','NWU Eagles','League Table',2,7,5,0,2,306,228,78,5,25,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/',now()),
('7461d49d-ebeb-445e-a24f-6bba098968d5','Maties','League Table',3,7,5,0,2,259,178,81,2,22,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/',now()),
('7461d49d-ebeb-445e-a24f-6bba098968d5','UJ','League Table',4,7,4,0,3,223,280,-57,2,18,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/',now()),
('7461d49d-ebeb-445e-a24f-6bba098968d5','UCT Ikeys','League Table',5,7,3,0,4,318,240,78,5,17,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/',now()),
('7461d49d-ebeb-445e-a24f-6bba098968d5','UFS Shimlas','League Table',6,7,3,0,4,250,242,8,1,13,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/',now()),
('7461d49d-ebeb-445e-a24f-6bba098968d5','Emeris','League Table',7,7,2,0,5,177,281,-104,3,11,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/',now()),
('7461d49d-ebeb-445e-a24f-6bba098968d5','CUT Ixias','League Table',8,7,0,0,7,172,391,-219,2,2,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/',now())
on conflict (competition_id,team_name,group_name) do update set
 position=excluded.position,played=excluded.played,won=excluded.won,drawn=excluded.drawn,lost=excluded.lost,
 scored=excluded.scored,conceded=excluded.conceded,points_difference=excluded.points_difference,
 bonus_points=excluded.bonus_points,points=excluded.points,source_url=excluded.source_url,
 source_checked_at=now(),updated_at=now();

insert into public.competition_team_statistics
(competition_id,team_name,statistics,source_url)
values
('7461d49d-ebeb-445e-a24f-6bba098968d5','UP Tuks','{"points_for":289,"points_against":154,"points_difference":135,"bonus_tries":4,"losing_bonus_points":0,"bonus_points":4,"log_points":28}'::jsonb,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/'),
('7461d49d-ebeb-445e-a24f-6bba098968d5','NWU Eagles','{"points_for":306,"points_against":228,"points_difference":78,"bonus_tries":3,"losing_bonus_points":2,"bonus_points":5,"log_points":25}'::jsonb,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/'),
('7461d49d-ebeb-445e-a24f-6bba098968d5','Maties','{"points_for":259,"points_against":178,"points_difference":81,"bonus_tries":2,"losing_bonus_points":0,"bonus_points":2,"log_points":22}'::jsonb,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/'),
('7461d49d-ebeb-445e-a24f-6bba098968d5','UJ','{"points_for":223,"points_against":280,"points_difference":-57,"bonus_tries":2,"losing_bonus_points":0,"bonus_points":2,"log_points":18}'::jsonb,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/'),
('7461d49d-ebeb-445e-a24f-6bba098968d5','UCT Ikeys','{"points_for":318,"points_against":240,"points_difference":78,"bonus_tries":3,"losing_bonus_points":2,"bonus_points":5,"log_points":17}'::jsonb,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/'),
('7461d49d-ebeb-445e-a24f-6bba098968d5','UFS Shimlas','{"points_for":250,"points_against":242,"points_difference":8,"bonus_tries":1,"losing_bonus_points":0,"bonus_points":1,"log_points":13}'::jsonb,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/'),
('7461d49d-ebeb-445e-a24f-6bba098968d5','Emeris','{"points_for":177,"points_against":281,"points_difference":-104,"bonus_tries":2,"losing_bonus_points":1,"bonus_points":3,"log_points":11}'::jsonb,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/'),
('7461d49d-ebeb-445e-a24f-6bba098968d5','CUT Ixias','{"points_for":172,"points_against":391,"points_difference":-219,"bonus_tries":1,"losing_bonus_points":1,"bonus_points":2,"log_points":2}'::jsonb,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2026/')
on conflict (competition_id,team_name) do update set
 statistics=excluded.statistics,source_url=excluded.source_url,source_checked_at=now(),updated_at=now();