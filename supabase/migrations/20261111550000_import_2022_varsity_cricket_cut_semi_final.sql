-- Import the verified CUT semi-final result from the 2022 Varsity Cricket tournament.
-- Source: Varsity Sport, 4 October 2022:
-- https://www.varsitysportssa.com/post/gloves-are-off-as-nwu-and-maties-prepare-for-the-varsity-cricket-title-fight

insert into public.competition_matches
  (competition_id, source_match_id, starts_at, home_team, away_team,
   home_score, away_score, match_status, match_round, venue, source_url,
   source_checked_at, statistics)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2022f5a00001',
   '2022-varsity-cricket-nwu-cut-semi-final',
   '2022-10-04',
   'North-West University (NWU)',
   'Central University of Technology (CUT)',
   157, 152,
   'completed',
   'Semi-final',
   'LC de Villiers Sports Grounds, UP-Tuks, Pretoria',
   'https://www.varsitysportssa.com/post/gloves-are-off-as-nwu-and-maties-prepare-for-the-varsity-cricket-title-fight',
   now(),
   '{"innings":{"NWU":"157/6 (20 overs)","CUT":"152/6 (20 overs)"},"result":"NWU won by 5 runs","cut_performances":[{"player":"Delano Williams","batting":"26 not out off 9 balls","note":"Late innings contribution; CUT scored 32 runs in the final powerplay over"}],"source_note":"Match report gives the team totals and Delano Williams contribution; no other CUT batting/bowling figures have been added."}'::jsonb)
on conflict (competition_id, source_match_id) do update set
  starts_at=excluded.starts_at,
  home_team=excluded.home_team,
  away_team=excluded.away_team,
  home_score=excluded.home_score,
  away_score=excluded.away_score,
  match_status=excluded.match_status,
  match_round=excluded.match_round,
  venue=excluded.venue,
  source_url=excluded.source_url,
  source_checked_at=excluded.source_checked_at,
  statistics=excluded.statistics,
  updated_at=now();
