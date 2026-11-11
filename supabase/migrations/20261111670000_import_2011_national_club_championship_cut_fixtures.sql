-- Import the four CUT fixtures indexed for the 2011 South African National Club
-- Championships (Section One). CricketArchive match references are preserved in
-- source_match_id/statistics. Scorecard pages were not independently accessible
-- during this import, so scores, outcomes and player figures remain NULL/omitted.
--
-- Match index references:
-- 19 Sep: Nelson Mandela Metropolitan University v Central University of Technology
--   misc631564: https://archive.nzc.nz/Grounds/5438_misc.html
-- 20 Sep: Pretoria University v Central University of Technology
--   misc631570: https://archive.nzc.nz/Grounds/1649_misc.html
-- 22 Sep: Central University of Technology v Northwood Crusaders
--   misc631582: https://www.cricketarchive.com/Nottinghamshire/Players/82/82484/Miscellaneous_Matches.html
-- 23 Sep: Brackenfell v Central University of Technology
--   misc631584: https://accringtoncc.com/Players/422/422881/Miscellaneous_Matches.html
--
-- CUT's third-place finish is separately supported by the university's
-- institutional achievements record:
-- https://cms.cut.ac.za/Files/Froala/c0aea0d8-303b-44b9-a730-c647fed29d0d.pdf

insert into public.competition_matches
  (id, competition_id, source_match_id, starts_at, home_team, away_team,
   home_score, away_score, match_status, match_round, venue, source_url, statistics)
values
  (
    'a43e3a9b-7c4e-4d7e-9f7c-2011a0000001',
    'a43e3a9b-7c4e-4d7e-9f7c-2011c5a00001',
    'CricketArchive misc631564',
    '2011-09-19T00:00:00+02:00',
    'Nelson Mandela Metropolitan University',
    'Central University of Technology',
    null, null, 'completed', 'Section One', null,
    'https://archive.nzc.nz/Grounds/5438_misc.html',
    '{"scorecard_reference":"misc631564","scorecard_data":"not independently accessible; no score or player figures imported"}'::jsonb
  ),
  (
    'a43e3a9b-7c4e-4d7e-9f7c-2011a0000002',
    'a43e3a9b-7c4e-4d7e-9f7c-2011c5a00001',
    'CricketArchive misc631570',
    '2011-09-20T00:00:00+02:00',
    'Pretoria University',
    'Central University of Technology',
    null, null, 'completed', 'Section One', null,
    'https://archive.nzc.nz/Grounds/1649_misc.html',
    '{"scorecard_reference":"misc631570","scorecard_data":"not independently accessible; no score or player figures imported"}'::jsonb
  ),
  (
    'a43e3a9b-7c4e-4d7e-9f7c-2011a0000003',
    'a43e3a9b-7c4e-4d7e-9f7c-2011c5a00001',
    'CricketArchive misc631582',
    '2011-09-22T00:00:00+02:00',
    'Central University of Technology',
    'Northwood Crusaders',
    null, null, 'completed', 'Section One',
    'Will Hofmeyr Oval, Pretoria Boys High School',
    'https://www.cricketarchive.com/Nottinghamshire/Players/82/82484/Miscellaneous_Matches.html',
    '{"scorecard_reference":"misc631582","scorecard_data":"not independently accessible; no score or player figures imported"}'::jsonb
  ),
  (
    'a43e3a9b-7c4e-4d7e-9f7c-2011a0000004',
    'a43e3a9b-7c4e-4d7e-9f7c-2011c5a00001',
    'CricketArchive misc631584',
    '2011-09-23T00:00:00+02:00',
    'Brackenfell',
    'Central University of Technology',
    null, null, 'completed', 'Section One',
    'Mamelodi Oval, Pretoria',
    'https://accringtoncc.com/Players/422/422881/Miscellaneous_Matches.html',
    '{"scorecard_reference":"misc631584","scorecard_data":"not independently accessible; no score or player figures imported"}'::jsonb
  )
on conflict (id) do nothing;
