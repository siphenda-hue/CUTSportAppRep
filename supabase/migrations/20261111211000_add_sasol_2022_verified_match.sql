-- Correct the source-published 2022 Free State Sasol League row and add one verified CUT match result.
-- RSSSF lists Grassland as 12 played, 7W, 2D, 5L (internally inconsistent: W/D/L sum to 14).
-- Preserve the published values and source rather than silently recalculating them.
update public.competition_standings
set lost=5, points_difference=13, source_checked_at=now(), updated_at=now()
where competition_id='6c45083c-ce0c-48e0-be1d-c1eea248bb05'
  and team_name='Grassland Ladies FC' and group_name='Stream A';

insert into public.competition_matches
(competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,group_name,source_url,source_checked_at,statistics)
values
('6c45083c-ce0c-48e0-be1d-c1eea248bb05','sasol-fs-2022-round4-de-jaguars-cut-20220521',null,'De Jaguars FC','CUT FC',1,6,'completed','Round 4 — 21 May 2022','Stream A','https://gsport.co.za/kovsies-fc-maintain-dominance-in-free-state-leg-of-sasol-league/',now(),jsonb_build_object('match_date','2022-05-21','note','Published result: De Jaguars 1-6 CUT FC'))
on conflict (competition_id,source_match_id) do update set
home_team=excluded.home_team,away_team=excluded.away_team,home_score=excluded.home_score,away_score=excluded.away_score,
match_status=excluded.match_status,match_round=excluded.match_round,group_name=excluded.group_name,
source_url=excluded.source_url,source_checked_at=excluded.source_checked_at,statistics=excluded.statistics,updated_at=now();
