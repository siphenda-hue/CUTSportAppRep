-- The three CUT Varsity Netball 2026 player rows document Player of the Match awards.
-- Individual goal totals were not published in the source material used for these records.
-- The required integer total_goals field remains zero as a placeholder; explicitly mark it as unknown, not a verified zero.
UPDATE public.competition_player_statistics
SET statistics = COALESCE(statistics, '{}'::jsonb)
  || jsonb_build_object(
    'goal_scoring_data_status', 'not_published_in_available_sources',
    'goal_total_zero_is_placeholder', true,
    'goal_scoring_note', 'This row records an award, not an individual scoring total. Zero is a database placeholder and must not be interpreted as a verified zero-goal performance.'
  )
WHERE competition_id = 'af3b41bd-c692-4129-ae99-1fd9b94681c6'
  AND team_name = 'CUT'
  AND player_name IN ('Keletso Gontho', 'Tshegofatso Makoko', 'Thandolwethu Madime');