do $$
declare c2023 uuid;
begin
  insert into public.competitions (sport_id,name,season,start_date,end_date,venue,description,status)
  values ('4c1ccd6f-3965-422a-ad25-19aaa2797f23','Varsity Football Men','2023','2023-07-27','2023-09-07','South Africa','2023 Men''s Varsity Football. CUT finished 7th (second from bottom) with no wins, two draws and five losses; 5 goals scored, 15 conceded and 2 points. All seven CUT round-robin results imported.','completed')
  returning id into c2023;

  insert into public.competition_matches
  (competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,venue,source_url,statistics)
  values
  (c2023,'2023-vf-r1-cut-uwc','2023-07-27 18:30:00+02','CUT','UWC',1,1,'completed','Round 1','CUT Stadium','https://www.varsitysportssa.com/post/mixed-results-on-the-first-day-of-varsity-football-action','{"scorers":{"CUT":["Pule Macdonald Thekiso"],"UWC":["Riyaaz Koopstadt"]},"player_of_match":"Riyaaz Koopstadt","player_of_match_team":"UWC"}'),
  (c2023,'2023-vf-r2-cut-tut','2023-08-03 18:30:00+02','CUT','TUT',2,6,'completed','Round 2','CUT Stadium','https://www.varsitysportssa.com/post/tut-s-mabaso-plans-to-continue-racking-up-the-goals','{"scorers":{"TUT":["Ronald Mabaso","Ronald Mabaso","Ronald Mabaso","Ronald Mabaso"]}}'),
  (c2023,'2023-vf-r3-ufh-cut','2023-08-10 00:00:00+02','UFH','CUT',0,0,'completed','Round 3','Davidson Stadium','https://threestreamsmedia.com/nwu-football-team-tackles-cut-in-varsity-cup/','{"result_note":"Goalless draw confirmed in match report"}'),
  (c2023,'2023-vf-r4-nwu-cut','2023-08-17 18:30:00+02','NWU','CUT',2,1,'completed','Round 4','NWU Mahikeng Stadium','https://www.varsitysportssa.com/post/drama-in-round-4-as-uj-go-top-of-the-log-uwc-beat-tut','{"scorers":{"NWU":["Aphelele Sibisi","Kgopotso Moshapo"],"CUT":["Lehlohonolo Nkaekae"]}}'),
  (c2023,'2023-vf-r5-uj-cut','2023-08-24 00:00:00+02','UJ','CUT',1,0,'completed','Round 5','UJ Soweto Stadium','https://news.uj.ac.za/news/uj-tops-the-log-after-round-5-of-mens-fnb-varsity-football-tournament/','{"scorers":{"UJ":["Siphosihle Nkambule"]}}'),
  (c2023,'2023-vf-r6-vut-cut','2023-08-31 00:00:00+02','VUT','CUT',1,0,'completed','Round 6','CUT Stadium','https://www.varsitysportssa.com/post/uj-tut-uwc-and-vut-edge-closer-to-semis-after-round-6','{"scorers":{"VUT":["Lucky Raphala"]}}'),
  (c2023,'2023-vf-r7-ufs-cut','2023-09-07 00:00:00+02','UFS','CUT',4,1,'completed','Round 7','Shimla Park','https://supersport.com/general/news/05c20e1b-9f2c-4779-bca5-27121a25d5b2/uj-uwc-tut-and-nwu-head-into-the-semifinals','{"scorers":{"UFS":["Sambulo Sithole","Sambulo Sithole","Omphemetse Athibeng","Boy Rantsotsi"],"CUT":["Own goal (Lesego Mafikeng)"]}}');

  insert into public.competition_standings
  (competition_id,team_name,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,points,source_url,source_checked_at)
  values
  (c2023,'CUT','CUT Team Summary',7,7,0,2,5,5,15,-10,2,'https://novanews.co.za/bloemnewsexpress/teams-study-self-20230912/',now());

  insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
  values
  (c2023,'CUT','{"matches_played":7,"wins":0,"draws":2,"losses":5,"goals_for":5,"goals_against":15,"goal_difference":-10,"league_points":2,"final_position":7,"known_named_scorers":{"Pule Macdonald Thekiso":1,"Lehlohonolo Nkaekae":1},"unattributed_goals":3}'::jsonb,'https://www.varsitysportssa.com/post/recap-of-the-2023-men-s-varsity-football-season-with-goals-and-highlights');

  insert into public.competition_player_statistics
  (competition_id,player_name,team_name,total_goals,statistics,source_url)
  values
  (c2023,'Pule Macdonald Thekiso','CUT',1,'{"goals":1,"scoring_match":"Round 1 vs UWC"}'::jsonb,'https://www.varsitysportssa.com/post/mixed-results-on-the-first-day-of-varsity-football-action'),
  (c2023,'Lehlohonolo Nkaekae','CUT',1,'{"goals":1,"scoring_match":"Round 4 vs NWU"}'::jsonb,'https://www.varsitysportssa.com/post/drama-in-round-4-as-uj-go-top-of-the-log-uwc-beat-tut');
end $$;