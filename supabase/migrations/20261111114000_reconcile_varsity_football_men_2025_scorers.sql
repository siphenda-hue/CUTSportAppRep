-- Reconcile verified CUT men's Varsity Football 2025 scorer records.
-- Round 1 report identifies Nkosingiphile Lubisi; Round 3 goal remains unattributed.
update public.competition_player_statistics
set total_goals = 3,
    statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
      'goals', 3,
      'scoring_matches', jsonb_build_array('Round 1 vs Wits','Round 4 vs DUT (2 goals)'),
      'player_of_match_award', true
    ),
    source_url = 'https://www.varsitysportssa.com/post/wits-and-tut-shine-in-varsity-football-2025-round-1',
    source_checked_at = now(),
    updated_at = now()
where competition_id = 'f925858a-c2e2-4622-903f-913646f6ca71'::uuid
  and team_name = 'CUT'
  and player_name = 'Nkosingiphile Lubisi';

update public.competition_player_statistics
set statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
      'goals', 1,
      'scoring_matches', jsonb_build_array('Round 5 vs UFS')
    ),
    source_url = 'https://www.varsitysportssa.com/post/ufs-roar-in-derby-as-nwu-edge-tut-in-varsity-cup-round-5',
    source_checked_at = now(),
    updated_at = now()
where competition_id = 'f925858a-c2e2-4622-903f-913646f6ca71'::uuid
  and team_name = 'CUT'
  and player_name = 'Katlego Ramotete';

update public.competition_team_statistics
set total_goals = 5,
    statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
      'goals_for', 5,
      'known_scorers', jsonb_build_object(
        'Nkosingiphile Lubisi', 3,
        'Katlego Ramotete', 1
      ),
      'documented_player_goals', 4,
      'unattributed_goals', 1,
      'scorer_goals_verified', 4,
      'known_top_scorer', 'Nkosingiphile Lubisi'
    ),
    source_url = 'https://www.varsitysportssa.com/post/recap-of-varsity-football-men-2025-with-goals-and-highlights',
    source_checked_at = now(),
    updated_at = now()
where competition_id = 'f925858a-c2e2-4622-903f-913646f6ca71'::uuid
  and team_name = 'CUT';