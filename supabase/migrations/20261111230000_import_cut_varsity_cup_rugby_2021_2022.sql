do $$
declare c2021 uuid; c2022 uuid;
begin
  insert into public.competitions (sport_id,name,season,start_date,end_date,venue,description,status)
  values ('83ddd3ad-ceef-4855-8e37-1303e388f58d','FNB Varsity Cup','2021','2021-04-04','2021-05-31','Pretoria bio-bubble','2021 FNB Varsity Cup men. CUT Ixias finished 5th in the final log with 6 wins, 3 losses and 29 log points. Janus Venter scored 12 tries and Cohen Jasper received the Player That Rocks award.','completed')
  returning id into c2021;

  insert into public.competitions (sport_id,name,season,start_date,end_date,venue,description,status)
  values ('83ddd3ad-ceef-4855-8e37-1303e388f58d','FNB Varsity Cup','2022','2022-02-14','2022-04-11','South Africa','2022 FNB Varsity Cup men. CUT Ixias finished the season without a win: 1 draw and 8 losses. The club remained in the Cup for 2023, ending the combined 2021/22 log four points clear of the relegation places.','completed')
  returning id into c2022;

  insert into public.competition_matches
  (competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,venue,source_url,statistics)
  values
  (c2021,'2021-vc-cut-uj','2021-04-04 00:00:00+02','CUT Ixias','UJ',46,13,'completed','League Round','Tuks Rugby Stadium, Pretoria','https://www.superbru.com/teams/?f=2&t=2317','{}'),
  (c2021,'2021-vc-nmu-cut','2021-04-08 00:00:00+02','NMU Madibaz','CUT Ixias',13,51,'completed','League Round','Loftus Versfeld, Pretoria','https://www.superbru.com/teams/?f=2&t=2317','{}'),
  (c2021,'2021-vc-cut-ufs','2021-04-11 00:00:00+02','CUT Ixias','UFS Shimlas',31,24,'completed','League Round','Tuks B-Field, Pretoria','https://www.superbru.com/teams/?f=2&t=2317','{}'),
  (c2021,'2021-vc-wits-cut','2021-04-22 00:00:00+02','Wits','CUT Ixias',11,19,'completed','League Round','Tuks B-Field, Pretoria','https://www.superbru.com/teams/?f=2&t=2317','{}'),
  (c2021,'2021-vc-uct-cut','2021-04-26 00:00:00+02','UCT Ikey Tigers','CUT Ixias',76,5,'completed','League Round','Tuks Rugby Stadium, Pretoria','https://www.superbru.com/teams/?f=2&t=2317','{}'),
  (c2021,'2021-vc-cut-maties','2021-04-30 00:00:00+02','CUT Ixias','Maties',23,18,'completed','League Round','Tuks B-Field, Pretoria','https://www.superbru.com/teams/?f=2&t=2317','{}'),
  (c2021,'2021-vc-uwc-cut','2021-05-20 00:00:00+02','UWC','CUT Ixias',60,19,'completed','League Round','Tuks Rugby Stadium, Pretoria','https://www.superbru.com/teams/?f=2&t=2317','{}'),
  (c2021,'2021-vc-tuks-cut','2021-05-23 00:00:00+02','UP Tuks','CUT Ixias',40,41,'completed','League Round','Loftus Versfeld, Pretoria','https://www.superbru.com/teams/?f=2&t=2317','{}'),
  (c2021,'2021-vc-cut-nwu','2021-05-25 00:00:00+02','CUT Ixias','NWU Eagles',32,35,'completed','League Round','Tuks B-Field, Pretoria','https://www.superbru.com/teams/?f=2&t=2317','{}');

  insert into public.competition_matches
  (competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,venue,source_url,statistics)
  values
  (c2022,'2022-vc-cut-uj','2022-02-14 00:00:00+02','CUT Ixias','UJ',44,44,'completed','Round 1','CUT Rugby Stadium, Bloemfontein','https://www.superbru.com/teams/?f=2&t=2317','{}'),
  (c2022,'2022-vc-wits-cut','2022-02-21 00:00:00+02','Wits','CUT Ixias',20,18,'completed','Round 2','Wits Rugby Stadium, Johannesburg','https://www.superbru.com/teams/?f=2&t=2317','{}'),
  (c2022,'2022-vc-cut-ufs','2022-02-28 00:00:00+02','CUT Ixias','UFS Shimlas',27,48,'completed','Round 3','CUT Rugby Stadium, Bloemfontein','https://www.cut.ac.za/news/varsity-cup-free-state-derby---ufs-shimlas-be','{"scorers":{"CUT":["Luvuyo Ndevu","Teboho Rampai","Penalty Try"],"UFS":["Thabang Mahlasi","William Moffat","Janco van Heyningin","Lourens Oosthuizen","Asanda Kunene","Lohan Potgieter","Ngobani Dlamini"]}}'),
  (c2022,'2022-vc-nmu-cut','2022-03-07 00:00:00+02','NMU Madibaz','CUT Ixias',36,26,'completed','Round 4','Madibaz Stadium, Gqeberha','https://www.superbru.com/teams/?f=2&t=2317','{}'),
  (c2022,'2022-vc-cut-maties','2022-03-14 00:00:00+02','CUT Ixias','Maties',19,52,'completed','Round 5','CUT Rugby Stadium, Bloemfontein','https://www.superbru.com/teams/?f=2&t=2317','{}'),
  (c2022,'2022-vc-tuks-cut','2022-03-21 00:00:00+02','UP Tuks','CUT Ixias',61,12,'completed','Round 6','Tuks Rugby Stadium, Pretoria','https://www.superbru.com/teams/?f=2&t=2317','{}'),
  (c2022,'2022-vc-uwc-cut','2022-03-28 00:00:00+02','UWC','CUT Ixias',44,38,'completed','Round 7','UWC Stadium, Cape Town','https://www.superbru.com/teams/?f=2&t=2317','{}'),
  (c2022,'2022-vc-cut-nwu','2022-04-04 00:00:00+02','CUT Ixias','NWU Eagles',14,33,'completed','Round 8','CUT Rugby Stadium, Bloemfontein','https://www.superbru.com/teams/?f=2&t=2317','{}'),
  (c2022,'2022-vc-uct-cut','2022-04-11 00:00:00+02','UCT Ikey Tigers','CUT Ixias',34,22,'completed','Round 9','UCT Rugby Fields, Cape Town','https://www.superbru.com/teams/?f=2&t=2317','{"scorers":{"CUT":["Jan Kotze","Matthew Sekele","Septimus Derkesen","Luvuyo Ndevu"],"conversions":["Floris Brand"]}}');

  insert into public.competition_standings
  (competition_id,team_name,group_name,position,played,won,drawn,lost,points_difference,bonus_points,points,source_url,source_checked_at)
  values
  (c2021,'UCT Ikey Tigers','League Table',1,9,8,1,0,174,7,41,'https://en.wikipedia.org/wiki/2021_Varsity_Cup',now()),
  (c2021,'Maties','League Table',2,9,7,0,2,160,7,35,'https://en.wikipedia.org/wiki/2021_Varsity_Cup',now()),
  (c2021,'UP Tuks','League Table',3,9,6,1,2,145,8,34,'https://en.wikipedia.org/wiki/2021_Varsity_Cup',now()),
  (c2021,'NWU Eagles','League Table',4,9,6,0,3,13,6,30,'https://en.wikipedia.org/wiki/2021_Varsity_Cup',now()),
  (c2021,'CUT Ixias','League Table',5,9,6,0,3,-25,5,29,'https://en.wikipedia.org/wiki/2021_Varsity_Cup',now()),
  (c2021,'UWC','League Table',6,9,3,1,5,0,6,20,'https://en.wikipedia.org/wiki/2021_Varsity_Cup',now()),
  (c2021,'UFS Shimlas','League Table',7,9,2,1,6,-119,8,18,'https://en.wikipedia.org/wiki/2021_Varsity_Cup',now()),
  (c2021,'Wits','League Table',8,9,3,0,6,37,5,17,'https://en.wikipedia.org/wiki/2021_Varsity_Cup',now()),
  (c2021,'UJ','League Table',9,9,2,0,7,-120,7,15,'https://en.wikipedia.org/wiki/2021_Varsity_Cup',now()),
  (c2021,'NMU Madibaz','League Table',10,9,0,0,9,-265,5,5,'https://en.wikipedia.org/wiki/2021_Varsity_Cup',now());

  insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
  values
  (c2021,'CUT Ixias','{"matches_played":9,"wins":6,"draws":0,"losses":3,"final_position":5,"log_points":29,"official_log_points_difference":-25,"try_bonus_points":5,"top_try_scorer":"Janus Venter","top_try_scorer_tries":12,"player_that_rocks":"Cohen Jasper"}'::jsonb,'https://en.wikipedia.org/wiki/2021_Varsity_Cup'),
  (c2022,'CUT Ixias','{"matches_played":9,"wins":0,"draws":1,"losses":8,"points_for":220,"points_against":372,"points_difference":-152,"combined_2021_2022_log_note":"Finished four log points clear of the bottom two and retained Varsity Cup status"}'::jsonb,'https://www.cut.ac.za/news/cut-ixias-stay-in-varsity-cup-despite-winless');

  insert into public.competition_player_statistics
  (competition_id,player_name,team_name,total_goals,statistics,source_url)
  values
  (c2021,'Janus Venter','CUT Ixias',0,'{"tries":12,"top_try_scorer":true}'::jsonb,'https://en.wikipedia.org/wiki/2021_Varsity_Cup'),
  (c2021,'Cohen Jasper','CUT Ixias',0,'{"player_that_rocks_award":true}'::jsonb,'https://en.wikipedia.org/wiki/2021_Varsity_Cup');
end $$;