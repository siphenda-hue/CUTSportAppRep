do $$
declare f2025 uuid;
begin
  select id into f2025 from public.competitions where sport_id='4c1ccd6f-3965-422a-ad25-19aaa2797f23' and name='Varsity Football Men' and season='2025' limit 1;
  update public.competition_matches
  set statistics='{"scorers":{"CUT":["Katlego Ramotete"],"UFS":["Kagiso Semenya","Jarome Jansen"]},"player_of_match":"Jarome Jansen","player_of_match_team":"UFS"}'::jsonb,
      source_url='https://www.varsitysportssa.com/post/ufs-roar-in-derby-as-nwu-edge-tut-in-varsity-cup-round-5'
  where competition_id=f2025 and source_match_id='2025-vf-r5-ufs-cut';

  insert into public.competition_player_statistics
  (competition_id,player_name,team_name,total_goals,statistics,source_url)
  values
  (f2025,'Katlego Ramotete','CUT',1,'{"goals":1,"scoring_match":"Round 5 vs UFS"}'::jsonb,'https://www.varsitysportssa.com/post/ufs-roar-in-derby-as-nwu-edge-tut-in-varsity-cup-round-5');

  update public.competition_team_statistics
  set statistics=statistics||jsonb_build_object('known_scorer_goals',3,'unattributed_goals',2,'known_scorers',jsonb_build_object('Nkosingiphile Lubisi',2,'Katlego Ramotete',1))
  where competition_id=f2025 and team_name='CUT';
end $$;