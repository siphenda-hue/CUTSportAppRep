do $$
declare c2021 uuid; c2022f uuid;
begin
  select id into c2021 from public.competitions where sport_id='83ddd3ad-ceef-4855-8e37-1303e388f58d' and name='FNB Varsity Cup' and season='2021' limit 1;
  select id into c2022f from public.competitions where sport_id='4c1ccd6f-3965-422a-ad25-19aaa2797f23' and name='Sasol Women''s League — Free State' and season='2022' limit 1;

  delete from public.competition_standings where competition_id=c2021 and team_name<>'CUT Ixias';
  update public.competition_standings
  set scored=267,conceded=290,points_difference=-23
  where competition_id=c2021 and team_name='CUT Ixias';

  update public.competition_team_statistics
  set statistics='{"matches_played":9,"wins":6,"draws":0,"losses":3,"final_position":5,"log_points":29,"match_results_points_for":267,"match_results_points_against":290,"match_results_points_difference":-23,"official_log_points_difference":-25,"source_difference_note":"Published final log lists a -25 points difference, while the nine published CUT match scores sum to -23; both values are retained transparently.","try_bonus_points":5,"top_try_scorer":"Janus Venter","top_try_scorer_tries":12,"player_that_rocks":"Cohen Jasper"}'::jsonb
  where competition_id=c2021 and team_name='CUT Ixias';

  delete from public.competition_standings where competition_id=c2022f and team_name='CUT Ladies (Ixias FC)';
end $$;