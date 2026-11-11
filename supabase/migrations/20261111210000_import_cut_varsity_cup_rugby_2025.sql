do $$
declare c2025 uuid;
begin
  insert into public.competitions (sport_id,name,season,start_date,end_date,venue,description,status)
  values ('83ddd3ad-ceef-4855-8e37-1303e388f58d','FNB Varsity Cup','2025','2025-02-17','2025-04-14','South Africa','2025 FNB Varsity Cup men. CUT Ixias finished 6th after a five-log-point sanction for an ineligible player in the Round 1 win over UJ. On-field record: 3 wins, 4 losses; 140 points for, 300 against, -160 difference. Final log points: 11. All seven CUT league results imported.','completed')
  returning id into c2025;

  insert into public.competition_matches
  (competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,venue,source_url,statistics)
  values
  (c2025,'2025-vc-r1-uj-cut','2025-02-17 19:00:00+02','UJ','CUT Ixias',13,29,'completed','Round 1','UJ Stadium','https://www.superbru.com/tournaments/rugby-union/varsity-cup/2025','{"official_result_note":"CUT was subsequently sanctioned and docked five log points for an ineligible player; match score retained."}'),
  (c2025,'2025-vc-r2-cut-uct','2025-02-24 19:00:00+02','CUT Ixias','UCT Ikeys',23,19,'completed','Round 2','CUT Rugby Stadium','https://www.superbru.com/tournaments/rugby-union/varsity-cup/2025','{}'),
  (c2025,'2025-vc-r3-maties-cut','2025-03-03 19:00:00+02','Maties','CUT Ixias',54,0,'completed','Round 3','Danie Craven Stadium','https://www.superbru.com/tournaments/rugby-union/varsity-cup/2025','{}'),
  (c2025,'2025-vc-r4-cut-tuks','2025-03-10 16:45:00+02','CUT Ixias','UP Tuks',26,63,'completed','Round 4','CUT Rugby Stadium','https://www.superbru.com/tournaments/rugby-union/varsity-cup/2025','{}'),
  (c2025,'2025-vc-r5-ufs-cut','2025-03-17 19:00:00+02','UFS Shimlas','CUT Ixias',16,9,'completed','Round 5','Shimla Park','https://www.superbru.com/tournaments/rugby-union/varsity-cup/2025','{}'),
  (c2025,'2025-vc-r6-cut-wits','2025-03-24 19:00:00+02','CUT Ixias','Wits',34,28,'completed','Round 6','CUT Rugby Stadium','https://www.superbru.com/tournaments/rugby-union/varsity-cup/2025','{}'),
  (c2025,'2025-vc-r7-nwu-cut','2025-03-31 19:00:00+02','NWU Eagles','CUT Ixias',107,19,'completed','Round 7','Fanie Du Toit Sports Grounds','https://www.superbru.com/tournaments/rugby-union/varsity-cup/2025','{}');

  insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
  values
  (c2025,'CUT Ixias','{"matches_played":7,"on_field_wins":3,"on_field_losses":4,"points_for":140,"points_against":300,"points_difference":-160,"final_log_position":6,"final_log_points":11,"log_points_deducted":5,"sanction":"Ineligible player in Round 1"}'::jsonb,'https://www.varsitycup.co.za/news/determined-ixias-galvanised-by-setbacks');
end $$;