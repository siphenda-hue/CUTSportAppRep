-- Reconcile verified CUT men's Varsity Football scorer coverage for 2023–2024.
-- 2023 Round 2 CUT scorers remain unnamed in the official season recap; do not invent identities.
-- 2023 UFS goal was an own goal; keep it separate from named player goals.
update public.competition_team_statistics
set total_goals = 5,
    statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
      'goals_for', 5,
      'known_named_scorers', jsonb_build_object(
        'Lehlohonolo Nkaekae', 1,
        'Pule Macdonald Thekiso', 1
      ),
      'documented_player_goals', 2,
      'unattributed_goals', 2,
      'own_goals_for', 1,
      'scorer_coverage_note', 'Two CUT goals against TUT are not individually attributed in the available official recap; one goal against UFS was an own goal.'
    ),
    source_url = 'https://www.varsitysportssa.com/post/recap-of-the-2023-men-s-varsity-football-season-with-goals-and-highlights',
    source_checked_at = now(),
    updated_at = now()
where competition_id = '0d4bd5f9-c2cd-42ae-927b-eabcf78258bb'::uuid
  and team_name = 'CUT';

-- The official Round 4 report names Lehakwe Phumo as CUT's scorer in the 4–1 loss to UWC.
insert into public.competition_player_statistics (
  competition_id, player_name, team_name, squad_number,
  field_goals, penalty_corner_goals, penalty_stroke_goals, total_goals,
  source_url, source_checked_at, created_at, updated_at, statistics
) values (
  'b8d5f59f-633f-4fc0-8b4b-ff2aa1c2bfc1'::uuid,
  'Lehakwe Phumo', 'CUT', null,
  1, 0, 0, 1,
  'https://www.varsitysportssa.com/post/up-tuks-remain-unbeaten-nwu-topple-tut-and-uwc-humble-cut-in-varsity-football-round-4',
  now(), now(), now(),
  jsonb_build_object('goals', 1, 'scoring_match', 'Round 4 vs UWC')
)
on conflict (competition_id, player_name, team_name)
do update set
  total_goals = 1,
  field_goals = 1,
  statistics = coalesce(public.competition_player_statistics.statistics, '{}'::jsonb)
    || jsonb_build_object('goals', 1, 'scoring_match', 'Round 4 vs UWC'),
  source_url = excluded.source_url,
  source_checked_at = now(),
  updated_at = now();

update public.competition_matches
set statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
      'scorers', jsonb_build_object('CUT', jsonb_build_array('Lehakwe Phumo')),
      'scorer_source_note', 'Official Varsity Sports Round 4 report'
    ),
    source_url = 'https://www.varsitysportssa.com/post/up-tuks-remain-unbeaten-nwu-topple-tut-and-uwc-humble-cut-in-varsity-football-round-4',
    source_checked_at = now(),
    updated_at = now()
where id = 'c64a4c0d-dc95-4bc7-9255-69492b92c37a'::uuid;

update public.competition_team_statistics
set total_goals = 5,
    statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
      'goals_for', 5,
      'known_named_scorers', jsonb_build_object(
        'Pule Thekiso', 1,
        'Pogisho Dikole', 2,
        'Nkosingiphile Libubisi', 1,
        'Lehakwe Phumo', 1
      ),
      'documented_player_goals', 5,
      'unattributed_goals', 0,
      'known_top_scorer', 'Pogisho Dikole',
      'scorer_coverage_note', 'All five CUT league goals are attributed in the available match reports.'
    ),
    source_url = 'https://www.varsitysportssa.com/post/up-tuks-remain-unbeaten-nwu-topple-tut-and-uwc-humble-cut-in-varsity-football-round-4',
    source_checked_at = now(),
    updated_at = now()
where competition_id = 'b8d5f59f-633f-4fc0-8b4b-ff2aa1c2bfc1'::uuid
  and team_name = 'CUT';