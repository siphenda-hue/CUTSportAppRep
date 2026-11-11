update public.competitions
set status='completed',
    description='CUT debut season in Varsity Netball (2026). CUT finished 7th with one win and six log points, retaining its place in the top division. All seven CUT league results and verified quarter-score details where published are recorded.'
where id='af3b41bd-c692-4129-ae99-1fd9b94681c6';

insert into public.competition_matches
(competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,venue,source_url,statistics)
values
('af3b41bd-c692-4129-ae99-1fd9b94681c6','2026-vn-r1-cut-wits','2026-08-23 00:00:00+02','CUT','Wits',43,48,'completed','Round 1','Maties Coetzenburg Indoor Centre','https://www.varsitysportssa.com/post/statement-win-for-nwu-thriller-between-kovsies-and-tuks-in-varsity-netball-round-1','{"quarter_scores":["9-10","18-22","28-37","43-48"],"player_of_match":"Keketso Molotsi","player_of_match_team":"Wits"}'),
('af3b41bd-c692-4129-ae99-1fd9b94681c6','2026-vn-r2-cut-uj','2026-08-24 15:00:00+02','CUT','UJ',36,57,'completed','Round 2','Maties Coetzenburg Indoor Centre','https://www.varsitysportssa.com/post/nwu-beat-tuks-in-one-goal-thriller-kovsies-hold-off-maties-in-varsity-netball-round-2','{"quarter_scores":["8-11","17-31","22-47","36-57"],"player_of_match":"Amara Agbai","player_of_match_team":"UJ"}'),
('af3b41bd-c692-4129-ae99-1fd9b94681c6','2026-vn-r3-tuks-cut','2026-08-30 00:00:00+02','UP-Tuks','CUT',59,45,'completed','Round 3','Callie Human Hall','https://www.varsitysportssa.com/post/uj-beat-defending-champs-nwu-while-kovsies-survive-wits-scare-in-varsity-netball-round-3','{"quarter_scores":["16-11","29-22","47-30","59-45"],"player_of_match":"Keletso Gontho","player_of_match_team":"CUT"}'),
('af3b41bd-c692-4129-ae99-1fd9b94681c6','2026-vn-r4-cut-madibaz','2026-08-31 00:00:00+02','CUT','NMU Madibaz',41,36,'completed','Round 4','Callie Human Hall, Bloemfontein','https://www.varsitysportssa.com/post/uj-claim-joburg-derby-spoils-nwu-and-ufs-nail-biter-in-varsity-netball-round-4','{"quarter_scores":["7-7","15-21","25-27","41-36"],"player_of_match":"Tshegofatso Makoko","player_of_match_team":"CUT"}'),
('af3b41bd-c692-4129-ae99-1fd9b94681c6','2026-vn-r5-cut-nwu','2026-09-06 00:00:00+02','CUT','NWU Eagles',37,60,'completed','Round 5','Wits Sports Hall, Johannesburg','https://supersport.com/football/news/0e818d8d-81c5-4029-a068-ced9826f62eb/varsity-netball-uj-still-unbeaten-victories-for-eagles-and-tuks','{"quarter_scores":["7-13","15-27","22-49","37-60"],"player_of_match":"Christi-Mari Coetzee","player_of_match_team":"NWU Eagles"}'),
('af3b41bd-c692-4129-ae99-1fd9b94681c6','2026-vn-r6-cut-maties','2026-09-13 00:00:00+02','CUT','Maties',50,52,'completed','Round 6','Rembrandt Hall, Pretoria','https://supersport.com/netball/news/bb8470c2-a421-4857-8826-702862eb20c0/tuks-shock-unbeaten-uj-while-maties-survive-close-call-v-cut-in-varsity-netball','{"quarter_scores":["9-18","22-28","37-38","50-52"],"player_of_match":"Thandolwethu Madime","player_of_match_team":"CUT"}'),
('af3b41bd-c692-4129-ae99-1fd9b94681c6','2026-vn-r7-cut-ufs','2026-09-14 00:00:00+02','CUT','UFS Kovsies',46,60,'completed','Round 7','Rembrandt Hall, Pretoria','https://www.varsitysportssa.com/post/varsity-netball-2026-semifinalists-decided-after-dramatic-round-7','{"quarter_scores_partial":["7-21","14-36"]}')
on conflict (competition_id,source_match_id) do update set
 starts_at=excluded.starts_at,home_team=excluded.home_team,away_team=excluded.away_team,
 home_score=excluded.home_score,away_score=excluded.away_score,match_status=excluded.match_status,
 match_round=excluded.match_round,venue=excluded.venue,source_url=excluded.source_url,
 statistics=excluded.statistics,source_checked_at=now(),updated_at=now();

insert into public.competition_standings
(competition_id,team_name,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,bonus_points,points,source_url,source_checked_at)
values
('af3b41bd-c692-4129-ae99-1fd9b94681c6','CUT','CUT Team Summary',7,7,1,0,6,298,372,-74,0,6,'https://novanews.co.za/bloemnewsexpress/powerhouses-reach-varsity-netball-semis-uj-chase-maiden-title/',now())
on conflict (competition_id,team_name,group_name) do update set
 position=excluded.position,played=excluded.played,won=excluded.won,drawn=excluded.drawn,lost=excluded.lost,
 scored=excluded.scored,conceded=excluded.conceded,points_difference=excluded.points_difference,
 bonus_points=excluded.bonus_points,points=excluded.points,source_url=excluded.source_url,
 source_checked_at=now(),updated_at=now();

insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
values
('af3b41bd-c692-4129-ae99-1fd9b94681c6','CUT','{"matches_played":7,"wins":1,"losses":6,"goals_for":298,"goals_against":372,"goal_difference":-74,"log_points":6,"final_position":7,"player_of_match_awards":{"Tshegofatso Makoko":1,"Keletso Gontho":1,"Thandolwethu Madime":1}}'::jsonb,'https://www.varsitysportssa.com/netball-fixtures')
on conflict (competition_id,team_name) do update set statistics=excluded.statistics,source_url=excluded.source_url,source_checked_at=now(),updated_at=now();

insert into public.competition_player_statistics
(competition_id,player_name,team_name,field_goals,penalty_corner_goals,penalty_stroke_goals,total_goals,statistics,source_url)
values
('af3b41bd-c692-4129-ae99-1fd9b94681c6','Tshegofatso Makoko','CUT',0,0,0,0,'{"player_of_match_awards":1,"award_round":"Round 4"}'::jsonb,'https://www.varsitysportssa.com/post/uj-claim-joburg-derby-spoils-nwu-and-ufs-nail-biter-in-varsity-netball-round-4'),
('af3b41bd-c692-4129-ae99-1fd9b94681c6','Keletso Gontho','CUT',0,0,0,0,'{"player_of_match_awards":1,"award_round":"Round 3"}'::jsonb,'https://www.varsitysportssa.com/post/uj-beat-defending-champs-nwu-while-kovsies-survive-wits-scare-in-varsity-netball-round-3'),
('af3b41bd-c692-4129-ae99-1fd9b94681c6','Thandolwethu Madime','CUT',0,0,0,0,'{"player_of_match_awards":1,"award_round":"Round 6"}'::jsonb,'https://supersport.com/netball/news/bb8470c2-a421-4857-8826-702862eb20c0/tuks-shock-unbeaten-uj-while-maties-survive-close-call-v-cut-in-varsity-netball')
on conflict (competition_id,player_name,team_name) do update set
 statistics=excluded.statistics,source_url=excluded.source_url,source_checked_at=now(),updated_at=now();