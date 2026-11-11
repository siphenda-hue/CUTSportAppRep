-- Import four verified CUT fixtures from the 2023 USSA Cricket A Week.
-- Published Club Cricket SA results provide the innings totals and outcomes.
-- CUT finished first in Pool B, Section 2 with three wins from three and qualified for the Section B final.
-- The final fixture is recorded in the source schedule, but its result is not added because it was not verified in the accessible report.

begin;

insert into public.competitions (id, sport_id, name, season, start_date, end_date, venue, description)
values (
  'a43e3a9b-7c4e-4d7e-9f7c-2023c5a00001',
  '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
  'USSA Cricket Tournament',
  '2023',
  '2023-12-04',
  '2023-12-08',
  'Cape Town, Western Cape, South Africa',
  'CUT Cricket competed in the 2023 USSA Cricket A Week in Cape Town. CUT finished first in Pool B, Section 2 with three wins from three: Rhodes (143/3 chasing 142), Nelson Mandela University B (117/3 chasing 116), and Fort Hare (350/4 against 169). CUT then defeated UCT by 22 runs (88/10 to 66/10) on 7 December to qualify for the Section B final scheduled against Varsity College on 8 December. The final result is not asserted because it is not confirmed by the accessible results report.'
)
on conflict (id) do update
set name=excluded.name, season=excluded.season, start_date=excluded.start_date,
    end_date=excluded.end_date, venue=excluded.venue, description=excluded.description;

insert into public.competition_matches (
  competition_id, source_match_id, starts_at, home_team, away_team,
  home_score, away_score, match_status, match_round, venue, source_url, statistics
)
values
(
  'a43e3a9b-7c4e-4d7e-9f7c-2023c5a00001',
  'ussa-cricket-2023-cut-vs-rhodes',
  null, 'CUT', 'Rhodes University', 143, 142, 'completed', 'Pool B, Section 2',
  'Northerns Goodwood Cricket Club, Cape Town, South Africa',
  'https://www.clubcricket.co.za/latestnews/ussa-a-tournament-results-and-scores-7-december-uwc-beat-uj-varsity-college-beat-madibaz-b/',
  '{"result":"CUT won by seven wickets","cut_innings":"143/3","opposition_innings":"142/10","match_date":"2023-12-04"}'::jsonb
),
(
  'a43e3a9b-7c4e-4d7e-9f7c-2023c5a00001',
  'ussa-cricket-2023-cut-vs-madibaz-b',
  null, 'CUT', 'Nelson Mandela University B', 117, 116, 'completed', 'Pool B, Section 2',
  'Cape Town Cricket Club, Cape Town, South Africa',
  'https://www.clubcricket.co.za/latestnews/ussa-a-tournament-results-and-scores-7-december-uwc-beat-uj-varsity-college-beat-madibaz-b/',
  '{"result":"CUT won by seven wickets","cut_innings":"117/3","opposition_innings":"116/10","match_date":"2023-12-05"}'::jsonb
),
(
  'a43e3a9b-7c4e-4d7e-9f7c-2023c5a00001',
  'ussa-cricket-2023-cut-vs-fort-hare',
  null, 'CUT', 'University of Fort Hare', 350, 169, 'completed', 'Pool B, Section 2',
  'Northerns Goodwood Cricket Club, Cape Town, South Africa',
  'https://www.clubcricket.co.za/latestnews/ussa-a-tournament-results-and-scores-7-december-uwc-beat-uj-varsity-college-beat-madibaz-b/',
  '{"result":"CUT won by 181 runs","cut_innings":"350/4","opposition_innings":"169/10","match_date":"2023-12-06"}'::jsonb
),
(
  'a43e3a9b-7c4e-4d7e-9f7c-2023c5a00001',
  'ussa-cricket-2023-cut-vs-uct',
  null, 'CUT', 'University of Cape Town', 88, 66, 'completed', 'Section B play-off',
  'Edgemead Cricket Club, Cape Town, South Africa',
  'https://www.clubcricket.co.za/latestnews/ussa-a-tournament-results-and-scores-7-december-uwc-beat-uj-varsity-college-beat-madibaz-b/',
  '{"result":"CUT won by 22 runs","cut_innings":"88/10","opposition_innings":"66/10","match_date":"2023-12-07"}'::jsonb
)
on conflict (competition_id, source_match_id) do update
set starts_at=excluded.starts_at, home_team=excluded.home_team, away_team=excluded.away_team,
    home_score=excluded.home_score, away_score=excluded.away_score, match_status=excluded.match_status,
    match_round=excluded.match_round, venue=excluded.venue, source_url=excluded.source_url,
    statistics=excluded.statistics;

commit;
