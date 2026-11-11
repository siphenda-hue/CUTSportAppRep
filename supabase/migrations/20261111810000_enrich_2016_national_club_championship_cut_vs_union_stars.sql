-- Enrich CUT's 26 April 2016 National Club Championship match vs Union Stars.
-- Source: SWD Cricket, "Union Stars performed well at Momentum National Club Championships",
-- published 3 May 2016. The report provides the match result and selected batting/bowling
-- figures; this is not a complete scorecard or tournament leaderboard.

update public.competition_matches
set home_score = 261,
    away_score = 89,
    statistics = coalesce(statistics, '{}'::jsonb) || '{
      "result":"Union Stars CC won by 172 runs",
      "union_stars_innings":"261/6 in 50 overs",
      "cut_innings":"89 all out in 29.5 overs",
      "scorecard_source":"SWD Cricket match summary, 3 May 2016"
    }'::jsonb,
    source_url = 'https://www.swdcricket.co.za/news/article/1400'
where competition_id = 'a43e3a9b-7c4e-4d7e-9f7c-2016c5a00001'
  and source_match_id = 'misc726769';

insert into public.competition_player_statistics
(id, competition_id, player_name, team_name, source_url, statistics)
values
('a6f16011-2016-4c01-9001-000000000011','a43e3a9b-7c4e-4d7e-9f7c-2016c5a00001','Rynard van Tonder','Central University of Technology','https://www.swdcricket.co.za/news/article/1400','{"runs":22,"match_date":"2016-04-26","match_opponent":"Union Stars","stat_category":"batting"}'::jsonb),
('a6f16012-2016-4c01-9001-000000000012','a43e3a9b-7c4e-4d7e-9f7c-2016c5a00001','Malusi Siboto','Central University of Technology','https://www.swdcricket.co.za/news/article/1400','{"wickets":4,"runs_conceded":41,"overs":10,"match_date":"2016-04-26","match_opponent":"Union Stars","stat_category":"bowling"}'::jsonb),
('a6f16013-2016-4c01-9001-000000000013','a43e3a9b-7c4e-4d7e-9f7c-2016c5a00001','Brendon Louw','Union Stars CC','https://www.swdcricket.co.za/news/article/1400','{"runs":61,"wickets":2,"runs_conceded":12,"bowling_overs":5,"bowling_maidens":1,"match_date":"2016-04-26","match_opponent":"Central University of Technology","stat_categories":["batting","bowling"]}'::jsonb),
('a6f16014-2016-4c01-9001-000000000014','a43e3a9b-7c4e-4d7e-9f7c-2016c5a00001','Sammy-Joe Avontuur','Union Stars CC','https://www.swdcricket.co.za/news/article/1400','{"runs":35,"match_date":"2016-04-26","match_opponent":"Central University of Technology","stat_category":"batting"}'::jsonb),
('a6f16015-2016-4c01-9001-000000000015','a43e3a9b-7c4e-4d7e-9f7c-2016c5a00001','Leroi Bredenkamp','Union Stars CC','https://www.swdcricket.co.za/news/article/1400','{"runs":69,"match_date":"2016-04-26","match_opponent":"Central University of Technology","stat_category":"batting"}'::jsonb),
('a6f16016-2016-4c01-9001-000000000016','a43e3a9b-7c4e-4d7e-9f7c-2016c5a00001','Marcello Piedt','Union Stars CC','https://www.swdcricket.co.za/news/article/1400','{"wickets":5,"runs_conceded":23,"overs":10,"maidens":3,"match_date":"2016-04-26","match_opponent":"Central University of Technology","stat_category":"bowling"}'::jsonb),
('a6f16017-2016-4c01-9001-000000000017','a43e3a9b-7c4e-4d7e-9f7c-2016c5a00001','Justin Jordaan','Central University of Technology','https://www.swdcricket.co.za/news/article/1400','{"wickets":2,"runs_conceded":14,"overs":5,"match_date":"2016-04-26","match_opponent":"Union Stars","stat_category":"bowling"}'::jsonb)
on conflict (competition_id, player_name, team_name) do update
set statistics = excluded.statistics,
    source_url = excluded.source_url;
