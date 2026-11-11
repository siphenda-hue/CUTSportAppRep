-- Import verified CUT men's USSA hockey records for 2018 and 2019.
-- Official SAHA AltiusRT competition pages are the source of results and standings.
-- The equivalent records were applied directly to Supabase and verified before this file was committed.
begin;

insert into public.competitions (id,sport_id,name,season,start_date,end_date,venue,description,status)
select 'b8182018-0000-4000-8000-000000000039','cc6888d8-dd80-470d-9046-2bddf1a6b19a','USSA Men B-Section','2018','2018-07-02','2018-07-06','Bloemfontein, Free State, South Africa','CUT competed in the 2018 USSA Men B-Section in Bloemfontein and finished sixth. The official SAHA record lists five CUT pool matches: losses to Kovsies (0–5), Rhodes (0–5), TUT (0–5), Vaal (0–5) and UKZN (0–5). CUT finished with 0 wins, 0 draws and 5 losses. No CUT player goal-scorer entries are published in the accessible record. Source: https://saha.altiusrt.com/competitions/39','completed'
where not exists (select 1 from public.competitions where id='b8182018-0000-4000-8000-000000000039' or (sport_id='cc6888d8-dd80-470d-9046-2bddf1a6b19a' and season='2018' and name='USSA Men B-Section'));

insert into public.competitions (id,sport_id,name,season,start_date,end_date,venue,description,status)
select 'b8192019-0000-4000-8000-000000000080','cc6888d8-dd80-470d-9046-2bddf1a6b19a','USSA Men C-Section','2019','2019-07-01','2019-07-05','Stellenbosch, Western Cape, South Africa','CUT competed in the 2019 USSA Men C-Section in Stellenbosch and finished fifth. In Pool A, CUT drew 5–5 with the University of Limpopo, lost 2–4 to Namibia University and lost 0–12 to UCT B. CUT then beat Mangosuthu University of Technology 18–1 in the 5th–8th play-off and beat Sol Plaatje University 4–1 in the 5th–6th placement match on 5 July. Pool A record: 3 played, 0 wins, 1 draw, 2 losses, 1 point. CUT scored 29 tournament goals (17 field goals, 11 penalty-corner goals, 1 penalty-stroke goal). Zandre Pretorius was the leading CUT scorer with 9 goals (7 field goals, 2 penalty-corner goals). Source: https://saha.altiusrt.com/competitions/80','completed'
where not exists (select 1 from public.competitions where id='b8192019-0000-4000-8000-000000000080' or (sport_id='cc6888d8-dd80-470d-9046-2bddf1a6b19a' and season='2019' and name='USSA Men C-Section'));

insert into public.competition_matches (id,competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,group_name,source_url,statistics)
select gen_random_uuid(),'b8182018-0000-4000-8000-000000000039',v.source_id,v.starts_at,v.home_team,v.away_team,v.home_score,v.away_score,'completed',v.match_round,'Pool A','https://saha.altiusrt.com/competitions/39',jsonb_build_object('source','SAHA AltiusRT','scorecard_available',true)
from (values
('2018-kovsies-cut',null::timestamptz,'University of the Free State (Kovsies)','CUT',5,0,'Pool A'),
('2018-rhodes-cut',null::timestamptz,'Rhodes University','CUT',5,0,'Pool A'),
('2018-cut-tut',null::timestamptz,'CUT','Tshwane University of Technology',0,5,'Pool A'),
('2018-cut-vaal',null::timestamptz,'CUT','Vaal University of Technology',0,5,'Pool A'),
('2018-ukzn-cut','2018-07-06'::timestamptz,'University of KwaZulu-Natal','CUT',5,0,'Pool A')
) v(source_id,starts_at,home_team,away_team,home_score,away_score,match_round)
where not exists (select 1 from public.competition_matches m where m.competition_id='b8182018-0000-4000-8000-000000000039' and m.source_match_id=v.source_id);

insert into public.competition_matches (id,competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,group_name,source_url,statistics)
select gen_random_uuid(),'b8192019-0000-4000-8000-000000000080',v.source_id,v.starts_at,v.home_team,v.away_team,v.home_score,v.away_score,'completed',v.match_round,v.group_name,'https://saha.altiusrt.com/competitions/80',jsonb_build_object('source','SAHA AltiusRT','scorecard_available',true)
from (values
('2019-cut-limpopo',null::timestamptz,'CUT','University of Limpopo',5,5,'Pool A','Pool A'),
('2019-cut-namibia',null::timestamptz,'CUT','Namibia University',2,4,'Pool A','Pool A'),
('2019-cut-uctb',null::timestamptz,'CUT','University of Cape Town B',0,12,'Pool A','Pool A'),
('2019-cut-mut',null::timestamptz,'CUT','Mangosuthu University of Technology',18,1,'Play-off 5–8','Placement'),
('2019-sol-cut','2019-07-05'::timestamptz,'Sol Plaatje University','CUT',1,4,'5th–6th place','Placement')
) v(source_id,starts_at,home_team,away_team,home_score,away_score,match_round,group_name)
where not exists (select 1 from public.competition_matches m where m.competition_id='b8192019-0000-4000-8000-000000000080' and m.source_match_id=v.source_id);

insert into public.competition_player_statistics (competition_id,player_name,team_name,field_goals,penalty_corner_goals,penalty_stroke_goals,total_goals,source_url,statistics)
select 'b8192019-0000-4000-8000-000000000080','Zandre Pretorius','CUT',7,2,0,9,'https://saha.altiusrt.com/competitions/80',jsonb_build_object('source','SAHA AltiusRT','stat_type','tournament_goal_scoring')
where not exists (select 1 from public.competition_player_statistics where competition_id='b8192019-0000-4000-8000-000000000080' and lower(trim(player_name))='zandre pretorius' and team_name='CUT');

commit;
