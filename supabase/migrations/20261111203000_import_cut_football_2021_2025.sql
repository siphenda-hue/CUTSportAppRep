do $$
declare
  men25 uuid;
  women21 uuid;
  women23 uuid;
  women24 uuid;
  women25 uuid;
begin
  insert into public.competitions (sport_id,name,season,start_date,end_date,venue,description,status)
  values ('4c1ccd6f-3965-422a-ad25-19aaa2797f23','Varsity Football Men','2025','2025-08-07','2025-09-18','South Africa','2025 Varsity Football men. CUT recorded one win and six losses in the seven-round league phase. CUT results, verified team scoring totals and the two-goal performance by Nkosingiphile Lubisi are recorded.','completed')
  returning id into men25;

  insert into public.competitions (sport_id,name,season,venue,description,status)
  values ('4c1ccd6f-3965-422a-ad25-19aaa2797f23','Sasol Women''s League — Free State','2021','Free State','Ixias FC (CUT Welkom) won the 2021 Free State provincial championship, defeating Kovsies FC 2-1 in Bethlehem on 30 October 2021. Ixias won Stream B with 32 points.','completed')
  returning id into women21;

  insert into public.competitions (sport_id,name,season,venue,description,status)
  values ('4c1ccd6f-3965-422a-ad25-19aaa2797f23','Sasol Women''s League — Free State','2023','Free State','Ixias FC (CUT Welkom) won the 2023 Free State provincial championship with a 1-0 victory over the University of the Free State in Virginia on 17 September 2023, qualifying for the 2023 national championship.','completed')
  returning id into women23;

  insert into public.competitions (sport_id,name,season,venue,description,status)
  values ('4c1ccd6f-3965-422a-ad25-19aaa2797f23','Sasol Women''s League — Free State','2024','Free State','Ixias FC finished first in Free State Stream A unbeaten: 14 played, 13 wins, 1 draw, 0 losses, 83 goals for, 1 against and 40 points. The provincial final finished 1-1; Kovsies advanced on penalties.','completed')
  returning id into women24;

  insert into public.competitions (sport_id,name,season,venue,description,status)
  values ('4c1ccd6f-3965-422a-ad25-19aaa2797f23','Sasol Women''s League — Free State','2025','Free State','CUT Ixias Ladies were crowned 2025 Free State Sasol Women''s League champions after beating Napoli Ladies 5-0 in the provincial play-offs, qualifying to represent the province at the SAFA National Women''s Football Tournament (8-13 December 2025).','completed')
  returning id into women25;

  insert into public.competition_matches
  (competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,venue,source_url,statistics)
  select men25,v.source_id,(v.match_date||' 00:00:00+02')::timestamptz,v.home_team,v.away_team,v.home_score,v.away_score,'completed',v.round_name,v.venue,v.source_url,v.stats::jsonb
  from (values
   ('2025-vf-r1-wits-cut','2025-08-07','Wits','CUT',4,1,'Round 1','Wits Rugby Stadium','https://www.varsitysportssa.com/post/wits-and-tut-shine-in-varsity-football-2025-round-1','{"scorers":{"CUT":"Not individually attributed in source"}}'),
   ('2025-vf-r2-nwu-cut','2025-08-14','NWU','CUT',1,0,'Round 2','NWU Mahikeng Stadium','https://www.varsitysportssa.com/post/round-2-matchday-wrap-uj-snatch-late-winner-while-wits-top-the-log','{"scorers":{"NWU":["Aphelele Sibisi"]}}'),
   ('2025-vf-r3-tut-cut','2025-08-21','TUT','CUT',3,1,'Round 3','TUT Stadium','https://www.varsitysportssa.com/post/recap-of-varsity-football-men-2025-with-goals-and-highlights','{}'),
   ('2025-vf-r4-cut-dut','2025-08-28','CUT','DUT',2,1,'Round 4','CUT Stadium','https://www.varsitysportssa.com/post/ufs-clutch-late-winner-and-uj-beat-tuks-to-go-top-of-the-log-after-round-4','{"scorers":{"CUT":["Nkosingiphile Lubisi","Nkosingiphile Lubisi"],"DUT":["Manqoba Mlele"]},"player_of_match":"Nkosingiphile Lubisi"}'),
   ('2025-vf-r5-ufs-cut','2025-09-04','UFS','CUT',2,1,'Round 5','Shimla Park','https://www.varsitysportssa.com/post/ufs-roar-in-derby-as-nwu-edge-tut-in-varsity-cup-round-5','{}'),
   ('2025-vf-r6-tuks-cut','2025-09-11','UP-Tuks','CUT',5,0,'Round 6','Tuks Stadium','https://www.varsitysportssa.com/post/recap-of-varsity-football-men-2025-with-goals-and-highlights','{}'),
   ('2025-vf-r7-cut-uj','2025-09-18','CUT','UJ',0,1,'Round 7','CUT Stadium','https://campaigns.supersport.com/football/general/news/b63d8e63-e6cf-4c44-82c0-cfa6a207bd14/varsity-football-2025-semifinals-confirmed-as-uj-ufs-nwu-and-tut-advance','{"scorers":{"UJ":["Tokoloho Vilakazi"]}}')
  ) as v(source_id,match_date,home_team,away_team,home_score,away_score,round_name,venue,source_url,stats);

  insert into public.competition_standings
  (competition_id,team_name,group_name,played,won,drawn,lost,scored,conceded,points_difference,points,source_url,source_checked_at)
  values
  (men25,'CUT','CUT Team Summary',7,1,0,6,5,17,-12,3,'https://www.soccermag.com/varsity-football/everything-that-happened-in-varsity-football-2025/',now());

  insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
  values
  (men25,'CUT','{"matches_played":7,"wins":1,"draws":0,"losses":6,"goals_for":5,"goals_against":17,"goal_difference":-12,"league_points":3,"scorer_goals_verified":2,"known_top_scorer":"Nkosingiphile Lubisi"}'::jsonb,'https://www.varsitysportssa.com/post/recap-of-varsity-football-men-2025-with-goals-and-highlights');

  insert into public.competition_player_statistics
  (competition_id,player_name,team_name,total_goals,statistics,source_url)
  values
  (men25,'Nkosingiphile Lubisi','CUT',2,'{"goals":2,"scoring_match":"Round 4 vs DUT","player_of_match_award":true}'::jsonb,'https://www.varsitysportssa.com/post/ufs-clutch-late-winner-and-uj-beat-tuks-to-go-top-of-the-log-after-round-4');

  insert into public.competition_matches
  (competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,venue,source_url,statistics)
  values
  (women21,'2021-fs-sasol-provincial-final-ixias-kovsies','2021-10-30 00:00:00+02','Ixias FC (CUT)','Kovsies FC (UFS)',2,1,'completed','Free State Provincial Final','Bethlehem','https://www.news24.com/southafrica/local/express-news/fs-title-defended-20211102','{"title":"Ixias retained the provincial title"}'),
  (women23,'2023-fs-sasol-provincial-final-ixias-ufs',null,'Ixias FC (CUT)','UFS Ladies',1,0,'completed','Free State Provincial Final — 1-0','Virginia','https://www.news24.com/community-newspaper/express-news/football-dream-kept-alive-20230919','{"match_date":"2023-09-17","title":"Ixias qualified for the national championship"}'),
  (women24,'2024-fs-sasol-provincial-final-ixias-kovsies',null,'Ixias FC (CUT)','Kovsies FC (UFS)',1,1,'completed','Free State Provincial Final — 1-1; Kovsies won on penalties','Bloemfontein','https://rsssf.org/tablesz/zaf-wom2024.html','{"shootout_winner":"Kovsies FC","shootout_score":"Not published in source"}'),
  (women25,'2025-fs-sasol-provincial-final-ixias-napoli',null,'CUT Ixias Ladies','Napoli Ladies',5,0,'completed','Free State Provincial Play-offs','Free State','https://www.cut.ac.za/news/cut-football-stars-set-for-national-stage-after-sasol-league-victory','{"title":"CUT crowned Free State champions","national_tournament_dates":"2025-12-08 to 2025-12-13"}');

  insert into public.competition_standings
  (competition_id,team_name,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,points,source_url,source_checked_at)
  values
  (women21,'Ixias FC (CUT)','Provincial Stream B',1,0,0,0,0,0,0,0,32,'https://www.news24.com/southafrica/local/express-news/fs-title-defended-20211102',now()),
  (women24,'Ixias FC (CUT)','Stream A',1,14,13,1,0,83,1,82,40,'https://fliphtml5.com/dafva/fnps/SAFA_Activity_Report_2024_Flipbook/',now());

  insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
  values
  (women21,'Ixias FC (CUT)','{"provincial_champions":true,"stream":"B","league_points":32,"provincial_final_score":"2-1","opponent":"Kovsies FC"}'::jsonb,'https://www.news24.com/southafrica/local/express-news/fs-title-defended-20211102'),
  (women23,'Ixias FC (CUT)','{"provincial_champions":true,"provincial_final_score":"1-0","opponent":"UFS Ladies","national_championship_qualified":true}'::jsonb,'https://www.news24.com/community-newspaper/express-news/football-dream-kept-alive-20230919'),
  (women24,'Ixias FC (CUT)','{"stream":"A","matches_played":14,"wins":13,"draws":1,"losses":0,"goals_for":83,"goals_against":1,"goal_difference":82,"league_points":40,"provincial_final":"1-1","provincial_final_shootout_lost":true}'::jsonb,'https://fliphtml5.com/dafva/fnps/SAFA_Activity_Report_2024_Flipbook/'),
  (women25,'CUT Ixias Ladies','{"provincial_champions":true,"provincial_final_score":"5-0","opponent":"Napoli Ladies","national_tournament_qualified":true,"national_tournament_start":"2025-12-08","national_tournament_end":"2025-12-13"}'::jsonb,'https://www.cut.ac.za/news/cut-football-stars-set-for-national-stage-after-sasol-league-victory');
end $$;