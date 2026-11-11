do $$
declare c2024 uuid;
begin
  insert into public.competitions (sport_id,name,season,start_date,end_date,venue,description,status)
  values ('4c1ccd6f-3965-422a-ad25-19aaa2797f23','Varsity Football Women','2024','2024-07-26','2024-08-09','TUT Stadium, Pretoria','2024 Women''s Varsity Football. CUT finished third in Group B (3 played, 1 win, 2 losses, 2 goals for, 10 against, 3 points) and sixth overall after losing the 5th/6th playoff 0-6 to UP-Tuks. All four CUT tournament matches imported.','completed')
  returning id into c2024;

  insert into public.competition_matches
  (competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,venue,source_url,statistics)
  values
  (c2024,'2024-wvf-r1-cput-cut','2024-07-26 12:00:00+02','CPUT','CUT',0,1,'completed','Group B — Round 1','TUT Stadium','https://www.varsitysportssa.com/post/uj-get-their-revenge-over-uwc-while-nwu-punish-wits-in-women-s-varsity-football-round-1','{"scorers":{"CUT":["Maleqhwa Mokoena"]},"player_of_match":"Keneilwe Nqai","player_of_match_team":"CUT"}'),
  (c2024,'2024-wvf-r2-cut-uwc','2024-07-27 17:00:00+02','CUT','UWC',1,6,'completed','Group B — Round 2','TUT Stadium','https://www.varsitysportssa.com/post/goals-galore-in-varsity-football-women-round-2-as-uwc-hammer-cut-and-big-wins-for-uj-and-tuks','{"scorers":{"CUT":["Keneilwe Nqai"],"UWC":["Ronnel Donnelly","Ronnel Donnelly","Chelsea Daniels","Chelsea Daniels","Chelsea Daniels","Thembelihle Zulu"]}}'),
  (c2024,'2024-wvf-r3-uj-cut','2024-07-28 17:00:00+02','UJ','CUT',4,0,'completed','Group B — Round 3','TUT Stadium','https://www.varsitysportssa.com/post/nwu-uj-uwc-and-tut-secure-semi-final-spots-after-women-s-varsity-football-round-3','{"scorers":{"UJ":["Sbongakonke Mzobe","Sphokazi Ngwenya","Shannon Macomo","Shannon Macomo"]}}'),
  (c2024,'2024-wvf-playoff-cut-tuks','2024-07-29 15:00:00+02','CUT','UP-Tuks',0,6,'completed','5th/6th Place Playoff','TUT Stadium','https://studentnews.africa/2024/07/uwc-will-take-on-tut-in-the-2024-varsity-womens-football-final/','{"scorers":{"UP-Tuks":["S’Bahle Ndlovu","S’Bahle Ndlovu","Tshwarelo Setlhafuno","Ntando Phahla","Ntando Phahla","Rethabile Makhwela"]}}');

  insert into public.competition_standings
  (competition_id,team_name,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,points,source_url,source_checked_at)
  values
  (c2024,'UJ','Group B',1,3,3,0,0,9,0,9,9,'https://en.wikipedia.org/wiki/2024_Women%27s_Varsity_Football',now()),
  (c2024,'UWC','Group B',2,3,2,0,1,8,2,6,6,'https://en.wikipedia.org/wiki/2024_Women%27s_Varsity_Football',now()),
  (c2024,'CUT','Group B',3,3,1,0,2,2,10,-8,3,'https://en.wikipedia.org/wiki/2024_Women%27s_Varsity_Football',now()),
  (c2024,'CPUT','Group B',4,3,0,0,3,0,7,-7,0,'https://en.wikipedia.org/wiki/2024_Women%27s_Varsity_Football',now());

  insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
  values
  (c2024,'CUT','{"group":"B","group_position":3,"group_matches_played":3,"group_wins":1,"group_losses":2,"group_goals_for":2,"group_goals_against":10,"group_points":3,"playoff_result":"0-6 vs UP-Tuks","final_tournament_position":6,"overall_matches_played":4,"overall_wins":1,"overall_losses":3,"overall_goals_for":2,"overall_goals_against":16}'::jsonb,'https://www.varsitysportssa.com/post/nwu-uj-uwc-and-tut-secure-semi-final-spots-after-women-s-varsity-football-round-3');

  insert into public.competition_player_statistics
  (competition_id,player_name,team_name,total_goals,statistics,source_url)
  values
  (c2024,'Maleqhwa Mokoena','CUT',1,'{"goals":1,"scoring_match":"Group B Round 1 vs CPUT"}'::jsonb,'https://www.varsitysportssa.com/post/uj-get-their-revenge-over-uwc-while-nwu-punish-wits-in-women-s-varsity-football-round-1'),
  (c2024,'Keneilwe Nqai','CUT',1,'{"goals":1,"scoring_match":"Group B Round 2 vs UWC","captain":true}'::jsonb,'https://www.varsitysportssa.com/post/goals-galore-in-varsity-football-women-round-2-as-uwc-hammer-cut-and-big-wins-for-uj-and-tuks');
end $$;