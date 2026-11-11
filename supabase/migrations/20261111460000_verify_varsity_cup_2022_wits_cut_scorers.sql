-- Restore verified CUT scorer data for the 21 February 2022 Wits 20-18 CUT Ixias match.
-- Source: Rugby365 Round Two wrap, which explicitly lists Jacquin van Wyk,
-- Tiaan Drotske and Kevin Strydom as CUT try scorers.
UPDATE public.competition_matches
SET source_url = 'https://rugby365.com/tournaments/varsity-cup/news-varsity-cup/varsity-cup-shimlas-stun-maties/',
    statistics = (
      COALESCE(statistics, '{}'::jsonb)
        - 'unverified_scorers'
        - 'scoring_audit_note'
    ) || jsonb_build_object(
      'scorers', jsonb_build_object(
        'Wits', jsonb_build_array('Setshaba Mokoena', 'Azi Afrika'),
        'CUT Ixias', jsonb_build_array('Jacquin van Wyk', 'Tiaan Drotske', 'Kevin Strydom')
      ),
      'scoring_data_status', 'verified_official_match_report',
      'scorer_source_note', 'Rugby365 Round Two wrap explicitly lists all three CUT try scorers; CUT also scored a penalty by Floris Brand.'
    )
WHERE id = '57a8e130-adde-4562-9a1d-139293d37472'
  AND home_team = 'Wits' AND home_score = 20
  AND away_team = 'CUT Ixias' AND away_score = 18;

UPDATE public.competition_player_statistics
SET statistics = jsonb_set(
  COALESCE(statistics, '{}'::jsonb),
  '{match_report_scope}',
  to_jsonb(COALESCE(statistics->>'match_report_scope','') || '; Wits v CUT (21 February 2022)'),
  true
)
WHERE competition_id = 'ecfa7e4b-cc49-4e78-8ada-280701fa3ff6'
  AND team_name = 'CUT Ixias'
  AND player_name IN ('Jacquin van Wyk','Tiaan Drotske');

INSERT INTO public.competition_player_statistics
  (competition_id, player_name, team_name, total_goals, statistics, source_url)
SELECT
  'ecfa7e4b-cc49-4e78-8ada-280701fa3ff6',
  'Kevin Strydom',
  'CUT Ixias',
  1,
  jsonb_build_object(
    'tries', 1,
    'verified_tries_in_available_match_reports', 1,
    'stat_scope', 'verified individual try scorers in eight available match reports; incomplete season coverage',
    'match_report_scope', 'Wits v CUT (21 February 2022)',
    'season_total_complete', false
  ),
  'https://rugby365.com/tournaments/varsity-cup/news-varsity-cup/varsity-cup-shimlas-stun-maties/'
WHERE NOT EXISTS (
  SELECT 1 FROM public.competition_player_statistics
  WHERE competition_id = 'ecfa7e4b-cc49-4e78-8ada-280701fa3ff6'
    AND team_name = 'CUT Ixias'
    AND player_name = 'Kevin Strydom'
);