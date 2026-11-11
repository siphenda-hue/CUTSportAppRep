do $$
declare c2024 uuid;
begin
  insert into public.competitions (sport_id,name,season,start_date,end_date,venue,description,status)
  values ('4c1ccd6f-3965-422a-ad25-19aaa2797f23','Varsity Football Men','2024','2024-07-25','2024-09-05','South Africa','2024 Men''s Varsity Football. CUT played seven league matches, recording two draws and five losses: 5 goals scored, 16 conceded and 2 points. Verified CUT results and named goal scorers are recorded; one CUT goal is not individually attributed in the available match reports.','completed')
  returning id into c2024;

  insert into public.competition_matches
  (competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,venue,source_url,statistics)
  values
  (c2024,'2024-vf-r1-cut-dut','2024-07-25 18:30:00+02','CUT','DUT',0,0,'completed','Round 1','CUT Stadium','https://www.varsitysportssa.com/post/cut-captain-simo-ndlovu-is-ready-for-opening-dut-clash','{}'),
  (c2024,'2024-vf-r2-cut-tuks','2024-08-01 18:30:00+02','CUT','UP-Tuks',1,4,'completed','Round 2','CUT Stadium','https://www.varsitysportssa.com/post/vut-shock-defending-champs-tut-in-round-2-of-varsity-football-2024','{"scorers":{"CUT":["Pogisho Dikole"],"UP-Tuks":["Raymond Tshwane Matlamela","Samukelo Ngodela","Tshepiso Mahlangu","Nkosana Shabalala"]}}'),
  (c2024,'2024-vf-r3-cut-vut','2024-08-08 18:30:00+02','CUT','VUT',2,2,'completed','Round 3','CUT Stadium','https://www.varsitysportssa.com/post/uwc-pick-up-first-win-a-thriller-in-bloem-and-up-tuks-remain-top-of-the-log-after-draw-with-nwu','{"scorers":{"CUT":["Nkosingiphile Libubisi","Pogisho Dikole"],"VUT":["Siyabonga Nombewu","Sibusiso Baloyi"]}}'),
  (c2024,'2024-vf-r4-uwc-cut','2024-08-15 18:30:00+02','UWC','CUT',4,1,'completed','Round 4','UWC Stadium','https://bloem-express.co.za/its-crunch-time-20240820','{}'),
  (c2024,'2024-vf-r5-cut-nwu','2024-08-22 18:30:00+02','CUT','NWU',0,3,'completed','Round 5','CUT Stadium','https://news.nwu.ac.za/taxonomy/term/1012?page=47','{"scorers":{"NWU":["Molemo Kukame","Momelezi Mngati"]}}'),
  (c2024,'2024-vf-r6-tut-cut','2024-08-29 18:30:00+02','TUT','CUT',2,1,'completed','Round 6','CUT Stadium','https://www.varsitysportssa.com/post/varsity-football-round-6-matchday-wrap-ufs-humble-uwc-in-bellville-while-tut-pick-up-their-first-wi','{"scorers":{"TUT":["Lesedi Nkosi","Swazi Kupa"],"CUT":["Pule Thekiso"]}}'),
  (c2024,'2024-vf-r7-cut-ufs','2024-09-05 18:30:00+02','CUT','UFS',0,1,'completed','Round 7','CUT Park','https://campaigns.supersport.com/football/general/news/70c25265-f1e4-4b2e-8fc0-a5293b3b1067/tuks-nwu-ufs-and-uwc-into-the-varsity-football-2024-semifinals','{"scorers":{"UFS":["Obakeng Seekoei"]}}');

  insert into public.competition_standings
  (competition_id,team_name,group_name,played,won,drawn,lost,scored,conceded,points_difference,points,source_url,source_checked_at)
  values
  (c2024,'CUT','CUT Team Summary',7,0,2,5,5,16,-11,2,'https://www.varsitysportssa.com/post/cut-vows-to-do-better-and-learn-from-the-varsity-football-experience',now());

  insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
  values
  (c2024,'CUT','{"matches_played":7,"wins":0,"draws":2,"losses":5,"goals_for":5,"goals_against":16,"goal_difference":-11,"league_points":2,"known_named_scorers":{"Pogisho Dikole":2,"Nkosingiphile Libubisi":1,"Pule Thekiso":1},"unattributed_goals":1}'::jsonb,'https://www.varsitysportssa.com/post/recap-of-the-2024-men-s-varsity-football-season-with-goals-and-highlights');

  insert into public.competition_player_statistics
  (competition_id,player_name,team_name,total_goals,statistics,source_url)
  values
  (c2024,'Pogisho Dikole','CUT',2,'{"goals":2,"scoring_matches":["Round 2 vs UP-Tuks","Round 3 vs VUT"]}'::jsonb,'https://www.varsitysportssa.com/post/vut-shock-defending-champs-tut-in-round-2-of-varsity-football-2024'),
  (c2024,'Nkosingiphile Libubisi','CUT',1,'{"goals":1,"scoring_match":"Round 3 vs VUT"}'::jsonb,'https://www.varsitysportssa.com/post/uwc-pick-up-first-win-a-thriller-in-bloem-and-up-tuks-remain-top-of-the-log-after-draw-with-nwu'),
  (c2024,'Pule Thekiso','CUT',1,'{"goals":1,"scoring_match":"Round 6 vs TUT"}'::jsonb,'https://www.varsitysportssa.com/post/varsity-football-round-6-matchday-wrap-ufs-humble-uwc-in-bellville-while-tut-pick-up-their-first-wi');
end $$;