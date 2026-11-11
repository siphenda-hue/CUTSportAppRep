-- Expand the two abbreviated 2015/16 CUT MCA League player names using
-- contemporary Netwerk24 coverage. Preserve the already-recorded figures.
update public.competition_player_statistics
set player_name='Koot Pienaar',
    source_url='https://www.netwerk24.com/cricket-making-strides-at-cut-20160720-2',
    statistics=coalesce(statistics,'{}'::jsonb) || '{"player_name_expansion_source":"Netwerk24","runs":160}'::jsonb
where id='b1600000-0000-4000-8000-000000000001';

update public.competition_player_statistics
set player_name='Marlon James',
    source_url='https://www.netwerk24.com/cricket-making-strides-at-cut-20160720-2',
    statistics=coalesce(statistics,'{}'::jsonb) || '{"player_name_expansion_source":"Netwerk24","wickets":6,"runs_conceded":20}'::jsonb
where id='b1600000-0000-4000-8000-000000000002';

update public.competitions
set description='CUT Cricket Club won the Mangaung Cricket Association Premier League during the 2015/16 season. Koot Pienaar scored 160 runs, the largest individual century reported in the MCA League, and Marlon James recorded the best reported bowling figures of 6/20. At the Free State Cricket Awards, Tshepo Ntuli received Senior Provincial Team Rookie of the Year and Romano Terblanche received Senior Provincial Team Player of the Year. CUT Cricket Club received Free State Cricket Club Championship Representative of the Year. These are reported season highlights and awards, not a complete scorecard or leaderboard. Sources: https://www.cut.ac.za/news/cut-cricket-flourishes ; https://www.netwerk24.com/cricket-making-strides-at-cut-20160720-2'
where id='a43e3a9b-7c4e-4d7e-9f7c-2015c5a00001';
