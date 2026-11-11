begin;

-- Complete round-by-round evidence for the two 2021 tournament leaderboard players.
update public.competition_player_statistics
set statistics = statistics || jsonb_build_object(
  'match_breakdown', jsonb_build_object(
    'Round 1', 2, 'Round 2', 2, 'Round 5', 1, 'Round 6', 1, 'Round 7', 1
  ),
  'match_breakdown_status', 'reconciled_to_published_match_scorer_lists'
)
where id = '13dcb6e0-2241-4548-b4d1-433c29a18382';

update public.competition_player_statistics
set statistics = statistics || jsonb_build_object(
  'match_breakdown', jsonb_build_object(
    'Round 1', 1, 'Round 2', 2, 'Round 4', 2, 'Round 6', 1, 'Round 7', 4, 'Round 8', 2
  ),
  'match_breakdown_status', 'reconciled_to_published_match_scorer_lists'
)
where id = '7aa7a39b-e199-4f5e-a4e3-42da5b8375d3';

-- The saved Wits v CUT 2022 scorer list pointed to an unrelated Shimlas v Maties report.
-- Preserve the old list for audit, but remove it from the trusted/displayable scorer field.
update public.competition_matches
set statistics = (statistics - 'scorers' - 'scoring_source')
  || jsonb_build_object(
       'unverified_scorers', statistics->'scorers',
       'scoring_data_status', 'unverified_source_mismatch',
       'scoring_audit_note', 'The previously attached Rugby365 URL is a Shimlas v Maties report, not Wits v CUT. The old scorer list is retained as unverified data and must not be treated as confirmed until a matching match report is found.'
     )
where id = '57a8e130-adde-4562-9a1d-139293d37472';

commit;