-- Correct the 2025 Varsity Cup Round 7 score using the official match report.
update public.competition_matches
set home_score = 117,
    away_score = 19,
    statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
      'scorers', jsonb_build_object(
        'NWU Eagles', jsonb_build_array(
          'Luan van der Walt (3)',
          'Naiden Jaarts (2)',
          'Tian van Zyl (2)',
          'Chyle van Zyl (2)',
          'Matthew Fortuin (2)',
          'Ntobeko Shezi',
          'Indiphile Tyeda',
          'Guhan du Bois',
          'Sean Roulston',
          'Sanele Zungu'
        ),
        'CUT Ixias', jsonb_build_array(
          'Zachery Bester',
          'Kevin Strydom',
          'Raydon Swartbooi'
        )
      ),
      'score_correction', 'Official Varsity Cup Round 7 report confirms 117-19; prior 107-19 value was incorrect.',
      'source_checked_at', now()
    ),
    source_url = 'https://www.varsitycup.co.za/news/fnb-varsity-cup-semi-finalists-confirmed-as-shimlas-stun-tuks-in-round-7',
    source_checked_at = now(),
    updated_at = now()
where id = '9745c279-9d5c-4551-9732-1331392d78f1'::uuid;

-- Reconcile CUT's 2025 season totals: points conceded rise by 10; points difference becomes -170.
update public.competition_standings
set conceded = 310,
    points_difference = -170,
    source_url = 'https://www.varsitycup.co.za/news/fnb-varsity-cup-semi-finalists-confirmed-as-shimlas-stun-tuks-in-round-7',
    source_checked_at = now(),
    updated_at = now()
where competition_id = '51cd131c-d9b4-4928-a741-c4a814ffc4b5'::uuid
  and team_name = 'CUT Ixias'
  and group_name = 'League Table';

update public.competition_team_statistics
set statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
      'points_for', 140,
      'points_against', 310,
      'points_difference_calculated_from_results', -170,
      'published_points_difference', -170,
      'source_note', 'Round 7 score corrected from 107-19 to the official 117-19. CUT season points against 310; points difference -170. Official final log points and sanction retained.'
    ),
    source_url = 'https://www.varsitycup.co.za/news/fnb-varsity-cup-semi-finalists-confirmed-as-shimlas-stun-tuks-in-round-7',
    source_checked_at = now(),
    updated_at = now()
where competition_id = '51cd131c-d9b4-4928-a741-c4a814ffc4b5'::uuid
  and team_name = 'CUT Ixias';

update public.competitions
set description = '2025 FNB Varsity Cup men. CUT Ixias finished 6th after a five-log-point sanction for an ineligible player in the Round 1 win over UJ. On-field record: 3 wins, 4 losses; 140 points for, 310 against, -170 difference. All seven CUT league results imported; Round 7 score corrected to the official NWU 117–19 CUT result. Final log points: 11. Official published bonus-point and log-point figures retained.'
where id = '51cd131c-d9b4-4928-a741-c4a814ffc4b5'::uuid;