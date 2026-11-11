-- Enrich CUT's 2015/16 MCA Premier League record with published season
-- highlights and Free State Cricket award recipients; clarify 2016 national
-- club championship dates and campaign record.
-- Source: CUT, "CUT Cricket flourishes", uploaded 3 June 2016:
-- https://www.cut.ac.za/news/cut-cricket-flourishes
--
-- The article states CUT won the 2015/16 MCA Premier League; K. Pienaar
-- scored 160; M. James recorded 6/20; Tshepo Ntuli and Romano Terblanche
-- received provincial awards; CUT Cricket Club received the club
-- championship representative award. It also confirms five national
-- championship matches in Pretoria in April 2016 (2 wins, 3 losses).
--
-- No unsupported individual national-championship scorecards or USSA
-- participation are inferred.

update public.competitions
set description = 'CUT Cricket Club won the Mangaung Cricket Association Premier League during the 2015/16 season. CUT’s K. Pienaar scored the largest century reported in the MCA League (160 runs), and M. James recorded the best reported bowling figures of 6/20. At the Free State Cricket Awards, Tshepo Ntuli received Senior Provincial Team Rookie of the Year and Romano Terblanche received Senior Provincial Team Player of the Year. CUT Cricket Club received Free State Cricket Club Championship Representative of the Year. These are reported season highlights and awards, not a complete scorecard or leaderboard. Source: https://www.cut.ac.za/news/cut-cricket-flourishes',
    status = 'completed'
where id = 'a43e3a9b-7c4e-4d7e-9f7c-2015c5a00001';

update public.competitions
set start_date = '2016-04-01',
    end_date = '2016-04-30',
    description = 'CUT Cricket Club represented Free State at the Momentum National Club Championships in Pretoria in April 2016, competing among the 12 best clubs in South Africa. CUT played five matches, winning two and losing three. No individual match results or player statistics are asserted. Source: https://www.cut.ac.za/news/cut-cricket-flourishes'
where id = 'a43e3a9b-7c4e-4d7e-9f7c-2016c5a00001';

insert into public.competition_player_statistics
(id, competition_id, player_name, team_name, field_goals, penalty_corner_goals, penalty_stroke_goals, total_goals, statistics, source_url)
values
('b1600000-0000-4000-8000-000000000001', 'a43e3a9b-7c4e-4d7e-9f7c-2015c5a00001', 'K. Pienaar', 'Central University of Technology', 0, 0, 0, 0, '{"runs":160,"stat_category":"batting","achievement":"largest individual century in the MCA League season"}'::jsonb, 'https://www.cut.ac.za/news/cut-cricket-flourishes'),
('b1600000-0000-4000-8000-000000000002', 'a43e3a9b-7c4e-4d7e-9f7c-2015c5a00001', 'M. James', 'Central University of Technology', 0, 0, 0, 0, '{"wickets":6,"runs_conceded":20,"stat_category":"bowling","achievement":"best bowling figures reported in the MCA League season"}'::jsonb, 'https://www.cut.ac.za/news/cut-cricket-flourishes'),
('b1600000-0000-4000-8000-000000000003', 'a43e3a9b-7c4e-4d7e-9f7c-2015c5a00001', 'Tshepo Ntuli', 'Central University of Technology', 0, 0, 0, 0, '{"award":"Senior Provincial Team Rookie of the Year","stat_category":"award"}'::jsonb, 'https://www.cut.ac.za/news/cut-cricket-flourishes'),
('b1600000-0000-4000-8000-000000000004', 'a43e3a9b-7c4e-4d7e-9f7c-2015c5a00001', 'Romano Terblanche', 'Central University of Technology', 0, 0, 0, 0, '{"award":"Senior Provincial Team Player of the Year","stat_category":"award"}'::jsonb, 'https://www.cut.ac.za/news/cut-cricket-flourishes')
on conflict (id) do update set
  player_name = excluded.player_name,
  team_name = excluded.team_name,
  statistics = excluded.statistics,
  source_url = excluded.source_url;
