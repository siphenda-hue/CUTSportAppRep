do $$
declare c2025 uuid;
begin
  insert into public.competitions (sport_id,name,season,start_date,end_date,venue,description,status)
  values ('4c1ccd6f-3965-422a-ad25-19aaa2797f23','SAFA Sasol League National Championship','2025','2025-12-08','2025-12-13','Vaal University of Technology, Vanderbijlpark','Ixias Ladies (CUT) represented Free State after winning the provincial Sasol League. CUT finished second in Group B with 4 points (1 win, 1 draw, 1 loss; 4 goals for, 5 against) and reached the semi-finals, where they lost 0-3 to Ramatlaohle Ladies.','completed')
  returning id into c2025;

  insert into public.competition_matches
  (competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,venue,source_url,statistics)
  values
  (c2025,'2025-sasol-nat-gb-4800-ixias','2025-12-09 13:00:00+02','4800 Ladies','Ixias Ladies (CUT)',1,2,'completed','Group B — Match 1','Vaal University of Technology, Vanderbijlpark','https://en.wikipedia.org/wiki/2025_Sasol_League_National_Championship','{}'),
  (c2025,'2025-sasol-nat-gb-ixias-superstrikers','2025-12-10 10:30:00+02','Ixias Ladies (CUT)','Super Strikers Ladies',1,3,'completed','Group B — Match 2','Vaal University of Technology, Vanderbijlpark','https://en.wikipedia.org/wiki/2025_Sasol_League_National_Championship','{}'),
  (c2025,'2025-sasol-nat-gb-ixias-allstars','2025-12-10 16:00:00+02','Ixias Ladies (CUT)','All Stars',1,1,'completed','Group B — Match 3','Vaal University of Technology, Vanderbijlpark','https://en.wikipedia.org/wiki/2025_Sasol_League_National_Championship','{}'),
  (c2025,'2025-sasol-nat-sf-ramatlaohle-ixias','2025-12-12 12:00:00+02','Ramatlaohle Ladies','Ixias Ladies (CUT)',3,0,'completed','Semi-final','Vaal University of Technology, Vanderbijlpark','https://en.wikipedia.org/wiki/2025_Sasol_League_National_Championship','{"result":"CUT eliminated in the semi-final"}');

  insert into public.competition_standings
  (competition_id,team_name,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,points,source_url,source_checked_at)
  values
  (c2025,'Super Strikers Ladies','Group B',1,3,3,0,0,11,2,9,9,'https://en.wikipedia.org/wiki/2025_Sasol_League_National_Championship',now()),
  (c2025,'Ixias Ladies (CUT)','Group B',2,3,1,1,1,4,5,-1,4,'https://en.wikipedia.org/wiki/2025_Sasol_League_National_Championship',now()),
  (c2025,'4800 Ladies','Group B',3,3,1,0,2,2,8,-6,3,'https://en.wikipedia.org/wiki/2025_Sasol_League_National_Championship',now()),
  (c2025,'All Stars','Group B',4,3,0,1,2,2,4,-2,1,'https://en.wikipedia.org/wiki/2025_Sasol_League_National_Championship',now());

  insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
  values
  (c2025,'Ixias Ladies (CUT)','{"group":"B","group_position":2,"group_matches_played":3,"group_wins":1,"group_draws":1,"group_losses":1,"group_goals_for":4,"group_goals_against":5,"group_goal_difference":-1,"group_points":4,"semi_final_result":"0-3 vs Ramatlaohle Ladies","final_status":"Semi-finalists"}'::jsonb,'https://en.wikipedia.org/wiki/2025_Sasol_League_National_Championship');
end $$;