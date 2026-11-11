do $$
declare
  c2023 uuid;
  c2024 uuid;
begin
  insert into public.competitions (sport_id,name,season,start_date,end_date,venue,description,status)
  values ('83ddd3ad-ceef-4855-8e37-1303e388f58d','FNB Varsity Cup','2023','2023-02-20','2023-04-17','South Africa','2023 FNB Varsity Cup men. CUT Ixias finished 7th with 3 wins, 4 losses, 262 points for, 321 against and 15 log points. Full CUT league fixtures/results and final league table imported.','completed')
  returning id into c2023;

  insert into public.competitions (sport_id,name,season,start_date,end_date,venue,description,status)
  values ('83ddd3ad-ceef-4855-8e37-1303e388f58d','FNB Varsity Cup','2024','2024-02-19','2024-04-22','South Africa','2024 FNB Varsity Cup men. CUT Ixias finished 7th with 2 wins, 5 losses, 191 points for, 256 against and 12 log points. Full CUT league fixtures/results and final league table imported.','completed')
  returning id into c2024;

  insert into public.competition_matches
  (competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,venue,source_url,statistics)
  select c2023,v.source_id,v.starts_at::timestamptz,v.home_team,v.away_team,v.home_score,v.away_score,'completed',v.round_name,v.venue,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2023/','{"competition":"FNB Varsity Cup","sport":"Rugby Union"}'::jsonb
  from (values
   ('2023-vc-r1-cut-wits','2023-02-20 15:30:00+02','CUT Ixias','Wits',49,59,'Round 1','CUT Rugby Stadium'),
   ('2023-vc-r2-maties-cut','2023-02-27 19:00:00+02','Maties','CUT Ixias',19,23,'Round 2','Danie Craven Stadium'),
   ('2023-vc-r3-cut-tuks','2023-03-06 15:30:00+02','CUT Ixias','UP Tuks',41,39,'Round 3','CUT Rugby Stadium'),
   ('2023-vc-r4-uj-cut','2023-03-13 16:00:00+02','UJ','CUT Ixias',12,54,'Round 4','UJ Stadium'),
   ('2023-vc-r5-nwu-cut','2023-03-20 19:00:00+02','NWU Eagles','CUT Ixias',45,28,'Round 5','Fanie Du Toit Sports Grounds'),
   ('2023-vc-r6-ufs-cut','2023-03-27 19:00:00+02','UFS Shimlas','CUT Ixias',68,36,'Round 6','Shimla Park'),
   ('2023-vc-r7-cut-uct','2023-04-03 15:30:00+02','CUT Ixias','UCT Ikeys',31,79,'Round 7','CUT Rugby Stadium')
  ) as v(source_id,starts_at,home_team,away_team,home_score,away_score,round_name,venue);

  insert into public.competition_matches
  (competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,venue,source_url,statistics)
  select c2024,v.source_id,v.starts_at::timestamptz,v.home_team,v.away_team,v.home_score,v.away_score,'completed',v.round_name,v.venue,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2024/','{"competition":"FNB Varsity Cup","sport":"Rugby Union"}'::jsonb
  from (values
   ('2024-vc-r1-cut-uj','2024-02-19 19:00:00+02','CUT Ixias','UJ',23,19,'Round 1','CUT Rugby Stadium'),
   ('2024-vc-r2-wits-cut','2024-02-26 19:00:00+02','Wits','CUT Ixias',34,17,'Round 2','Wits Rugby Stadium'),
   ('2024-vc-r3-uwc-cut','2024-03-04 16:45:00+02','UWC','CUT Ixias',21,38,'Round 3','UWC Stadium'),
   ('2024-vc-r4-uct-cut','2024-03-11 19:00:00+02','UCT Ikeys','CUT Ixias',44,7,'Round 4','The Green Mile'),
   ('2024-vc-r5-cut-ufs','2024-03-18 19:00:00+02','CUT Ixias','UFS Shimlas',40,59,'Round 5','CUT Rugby Stadium'),
   ('2024-vc-r6-cut-nwu','2024-03-25 19:00:00+02','CUT Ixias','NWU Eagles',46,53,'Round 6','CUT Rugby Stadium'),
   ('2024-vc-r7-cut-maties','2024-04-08 16:45:00+02','CUT Ixias','Maties',20,26,'Round 7','CUT Rugby Stadium')
  ) as v(source_id,starts_at,home_team,away_team,home_score,away_score,round_name,venue);

  insert into public.competition_standings
  (competition_id,team_name,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,bonus_points,points,source_url,source_checked_at)
  select c2023,v.team_name,'League Table',v.position,7,v.won,0,v.lost,v.pf,v.pa,v.pd,v.bp,v.pts,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2023/',now()
  from (values
   ('NWU Eagles',1,6,1,281,154,127,3,27),('UFS Shimlas',2,5,2,223,220,3,2,22),
   ('UCT Ikeys',3,4,3,263,187,76,5,21),('Maties',4,4,3,223,250,-27,3,19),
   ('UJ',5,3,4,231,254,-23,5,17),('Wits',6,3,4,228,267,-39,4,16),
   ('CUT Ixias',7,3,4,262,321,-59,3,15),('UP Tuks',8,0,7,192,250,-58,5,5)
  ) as v(team_name,position,won,lost,pf,pa,pd,bp,pts);

  insert into public.competition_standings
  (competition_id,team_name,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,bonus_points,points,source_url,source_checked_at)
  select c2024,v.team_name,'League Table',v.position,7,v.won,v.drawn,v.lost,v.pf,v.pa,v.pd,v.bp,v.pts,'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2024/',now()
  from (values
   ('NWU Eagles',1,6,0,1,281,160,121,4,28),('Maties',2,6,0,1,231,130,101,2,26),
   ('UFS Shimlas',3,5,0,2,261,211,50,5,25),('UCT Ikeys',4,4,1,2,266,147,119,3,21),
   ('Wits',5,2,1,4,205,207,-2,3,13),('UJ',6,2,0,5,213,226,-13,5,13),
   ('CUT Ixias',7,2,0,5,191,256,-65,4,12),('UWC',8,0,0,7,103,414,-311,0,0)
  ) as v(team_name,position,won,drawn,lost,pf,pa,pd,bp,pts);

  insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
  select c2023,v.team_name,jsonb_build_object('points_for',v.pf,'points_against',v.pa,'points_difference',v.pd,'bonus_points',v.bp,'log_points',v.pts),'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2023/'
  from (values
   ('NWU Eagles',281,154,127,3,27),('UFS Shimlas',223,220,3,2,22),('UCT Ikeys',263,187,76,5,21),('Maties',223,250,-27,3,19),
   ('UJ',231,254,-23,5,17),('Wits',228,267,-39,4,16),('CUT Ixias',262,321,-59,3,15),('UP Tuks',192,250,-58,5,5)
  ) as v(team_name,pf,pa,pd,bp,pts);

  insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
  select c2024,v.team_name,jsonb_build_object('points_for',v.pf,'points_against',v.pa,'points_difference',v.pd,'bonus_points',v.bp,'log_points',v.pts),'https://www.superbru.com/tournaments/rugby-union/varsity-cup/2024/'
  from (values
   ('NWU Eagles',281,160,121,4,28),('Maties',231,130,101,2,26),('UFS Shimlas',261,211,50,5,25),('UCT Ikeys',266,147,119,3,21),
   ('Wits',205,207,-2,3,13),('UJ',213,226,-13,5,13),('CUT Ixias',191,256,-65,4,12),('UWC',103,414,-311,0,0)
  ) as v(team_name,pf,pa,pd,bp,pts);
end $$;