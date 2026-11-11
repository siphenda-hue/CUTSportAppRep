-- Complete the verified CUT player award and team goal total for 2024 Women's Varsity Football.
update public.competition_player_statistics
set statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
  'awards',
  coalesce(statistics->'awards', '[]'::jsonb) ||
  '[{"award":"FNB Player of the Match","match":"Group B Round 1 vs CPUT","date":"2024-07-26"}]'::jsonb
),
source_url = 'https://www.varsitysportssa.com/post/uj-get-their-revenge-over-uwc-while-nwu-punish-wits-in-women-s-varsity-football-round-1',
source_checked_at = now(),
updated_at = now()
where competition_id = 'ff012715-ae52-4b1d-b3a4-d6c528d27112'::uuid
  and player_name = 'Keneilwe Nqai'
  and team_name = 'CUT'
  and not (coalesce(statistics->'awards','[]'::jsonb) @> '[{"award":"FNB Player of the Match","match":"Group B Round 1 vs CPUT"}]'::jsonb);

update public.competition_team_statistics
set total_goals = 2,
    statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
      'verified_scorers', jsonb_build_array(
        jsonb_build_object('player','Maleqhwa Mokoena','goals',1,'match','Group B Round 1 vs CPUT'),
        jsonb_build_object('player','Keneilwe Nqai','goals',1,'match','Group B Round 2 vs UWC')
      ),
      'scorer_coverage', 'all published CUT tournament goals'
    ),
    source_url = 'https://www.varsitysportssa.com/post/goals-galore-in-varsity-football-women-round-2-as-uwc-hammer-cut-and-big-wins-for-uj-and-tuks',
    source_checked_at = now(),
    updated_at = now()
where competition_id = 'ff012715-ae52-4b1d-b3a4-d6c528d27112'::uuid
  and team_name = 'CUT';