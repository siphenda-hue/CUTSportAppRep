-- Import CUT's 2012 CSA National Club Championship Section Two campaign.
-- Contemporary SWD Cricket coverage verifies the 23 April result and Ian O'Neill's 97.
-- CricketArchive indexes the additional fixtures; inaccessible scorecards are not inferred.

insert into public.competitions (
  id, sport_id, name, season, start_date, end_date, venue, description, status
) values (
  'a43e3a9b-7c4e-4d7e-9f7c-2012c5a00002',
  '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
  'National Club Championship',
  '2012',
  '2012-04-23',
  '2012-04-27',
  'Pretoria, Gauteng, South Africa',
  'CUT competed in Section Two of the 2012 Cricket South Africa National Club Championships in Pretoria. A contemporary SWD Cricket report confirms CUT beat the University of the Western Cape by 22 runs: CUT 243/7 (50 overs), UWC 188 all out (34.5 overs); Ian O’Neill scored 97. CricketArchive indexes additional CUT fixtures against Nelson Mandela Metropolitan University (25 April), North West University (26 April) and Northwood Crusaders (27 April). Scores and outcomes for those fixtures are not asserted.',
  'completed'
)
on conflict (id) do update set
  name = excluded.name,
  season = excluded.season,
  start_date = excluded.start_date,
  end_date = excluded.end_date,
  venue = excluded.venue,
  description = excluded.description,
  status = excluded.status;

insert into public.competition_matches (
  id, competition_id, source_match_id, starts_at, home_team, away_team,
  home_score, away_score, match_status, match_round, group_name, source_url, statistics
) values
(
  'a43e3a9b-7c4e-4d7e-9f7c-2012c5a00011',
  'a43e3a9b-7c4e-4d7e-9f7c-2012c5a00002',
  'SWD-2012-04-23-UWC-CUT',
  '2012-04-23T00:00:00Z',
  'University of the Western Cape',
  'Central University of Technology',
  188, 243, 'completed', 'Section Two', 'Section Two',
  'https://www.swdcricket.co.za/news/article/501',
  '{"result":"CUT won by 22 runs","cut_innings":"243/7 in 50 overs","opponent_innings":"188 all out in 34.5 overs"}'::jsonb
),
(
  'a43e3a9b-7c4e-4d7e-9f7c-2012c5a00012',
  'a43e3a9b-7c4e-4d7e-9f7c-2012c5a00002',
  'CA-misc631651',
  '2012-04-25T00:00:00Z',
  'Central University of Technology',
  'Nelson Mandela Metropolitan University',
  null, null, 'completed', 'Section Two', 'Section Two',
  'https://cricketarchive.com/Archive/Grounds/23/1649_misc.html',
  '{"scorecard_verified":false}'::jsonb
),
(
  'a43e3a9b-7c4e-4d7e-9f7c-2012c5a00013',
  'a43e3a9b-7c4e-4d7e-9f7c-2012c5a00002',
  'CA-misc631657',
  '2012-04-26T00:00:00Z',
  'Central University of Technology',
  'North West University',
  null, null, 'completed', 'Section Two', 'Section Two',
  'https://cricketarchive.com/Archive/Grounds/23/1649_misc.html',
  '{"scorecard_verified":false}'::jsonb
),
(
  'a43e3a9b-7c4e-4d7e-9f7c-2012c5a00014',
  'a43e3a9b-7c4e-4d7e-9f7c-2012c5a00002',
  'CA-misc631661',
  '2012-04-27T00:00:00Z',
  'Northwood Crusaders',
  'Central University of Technology',
  null, null, 'completed', 'Section Two', 'Section Two',
  'https://cricketarchive.com/Archive/Grounds/23/1649_misc.html',
  '{"scorecard_verified":false}'::jsonb
)
on conflict (id) do update set
  source_match_id = excluded.source_match_id,
  starts_at = excluded.starts_at,
  home_team = excluded.home_team,
  away_team = excluded.away_team,
  home_score = excluded.home_score,
  away_score = excluded.away_score,
  match_status = excluded.match_status,
  match_round = excluded.match_round,
  group_name = excluded.group_name,
  source_url = excluded.source_url,
  statistics = excluded.statistics;

insert into public.competition_player_statistics (
  id, competition_id, player_name, team_name, source_url, statistics
) values (
  'a43e3a9b-7c4e-4d7e-9f7c-2012c5a00021',
  'a43e3a9b-7c4e-4d7e-9f7c-2012c5a00002',
  'Ian O’Neill',
  'Central University of Technology',
  'https://www.swdcricket.co.za/news/article/501',
  '{"runs":97,"stat_category":"batting","match_opponent":"University of the Western Cape","match_date":"2012-04-23"}'::jsonb
)
on conflict (id) do update set
  player_name = excluded.player_name,
  team_name = excluded.team_name,
  source_url = excluded.source_url,
  statistics = excluded.statistics;
