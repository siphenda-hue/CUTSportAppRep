-- Import verified CUT Ixias try scorers from available 2022 FNB Varsity Cup match reports.
-- These are documented match-report totals, not complete season totals: four CUT match reports
-- were available with named scorers. Penalty tries are intentionally not attributed to players.
insert into public.competition_player_statistics
  (competition_id, player_name, team_name, total_goals, statistics, source_url, source_checked_at)
values
  ('ecfa7e4b-cc49-4e78-8ada-280701fa3ff6', 'Tiaan Drotske', 'CUT Ixias', 0,
   jsonb_build_object('tries', 1, 'verified_tries_in_available_match_reports', 1, 'season_total_complete', false,
     'match_report_scope', 'CUT v UJ; CUT v UFS Shimlas; CUT v UWC; UCT v CUT'),
   'https://www.cut.ac.za/news/varsity-cup-fnb-cut-met-fnb-uj-in-a-thrilling', now()),
  ('ecfa7e4b-cc49-4e78-8ada-280701fa3ff6', 'Ulrich Stander', 'CUT Ixias', 0,
   jsonb_build_object('tries', 1, 'verified_tries_in_available_match_reports', 1, 'season_total_complete', false,
     'match_report_scope', 'CUT v UJ; CUT v UFS Shimlas; CUT v UWC; UCT v CUT'),
   'https://www.cut.ac.za/news/varsity-cup-fnb-cut-met-fnb-uj-in-a-thrilling', now()),
  ('ecfa7e4b-cc49-4e78-8ada-280701fa3ff6', 'Teboho Rampai', 'CUT Ixias', 0,
   jsonb_build_object('tries', 2, 'verified_tries_in_available_match_reports', 2, 'season_total_complete', false,
     'match_report_scope', 'CUT v UJ; CUT v UFS Shimlas; CUT v UWC; UCT v CUT'),
   'https://iol.co.za/sport/rugby/2022-02-28-watch-ufs-shimlas-thump-cut-ixias-48-27-in-varsity-cup/', now()),
  ('ecfa7e4b-cc49-4e78-8ada-280701fa3ff6', 'Jacquin van Wyk', 'CUT Ixias', 0,
   jsonb_build_object('tries', 2, 'verified_tries_in_available_match_reports', 2, 'season_total_complete', false,
     'match_report_scope', 'CUT v UJ; CUT v UFS Shimlas; CUT v UWC; UCT v CUT'),
   'https://www.cut.ac.za/news/varsity-cup-fnb-cut-met-fnb-uj-in-a-thrilling', now()),
  ('ecfa7e4b-cc49-4e78-8ada-280701fa3ff6', 'Jan Kotze', 'CUT Ixias', 0,
   jsonb_build_object('tries', 2, 'verified_tries_in_available_match_reports', 2, 'season_total_complete', false,
     'match_report_scope', 'CUT v UJ; CUT v UFS Shimlas; CUT v UWC; UCT v CUT'),
   'https://www.cut.ac.za/news/cut-ixias-stay-in-varsity-cup-despite-winless', now()),
  ('ecfa7e4b-cc49-4e78-8ada-280701fa3ff6', 'Luvuyo Ndevu', 'CUT Ixias', 0,
   jsonb_build_object('tries', 2, 'verified_tries_in_available_match_reports', 2, 'season_total_complete', false,
     'match_report_scope', 'CUT v UJ; CUT v UFS Shimlas; CUT v UWC; UCT v CUT'),
   'https://iol.co.za/sport/rugby/2022-02-28-watch-ufs-shimlas-thump-cut-ixias-48-27-in-varsity-cup/', now()),
  ('ecfa7e4b-cc49-4e78-8ada-280701fa3ff6', 'Matthew Sekele', 'CUT Ixias', 0,
   jsonb_build_object('tries', 3, 'verified_tries_in_available_match_reports', 3, 'season_total_complete', false,
     'match_report_scope', 'CUT v UJ; CUT v UFS Shimlas; CUT v UWC; UCT v CUT',
     'additional_confirmation', 'Two tries versus UWC highlighted in the official 2022 Round 7 player feature'),
   'https://www.varsitycup.co.za/news/five-fnb-varsity-cup-players-who-impressed-round-7', now()),
  ('ecfa7e4b-cc49-4e78-8ada-280701fa3ff6', 'Septimus Derkesen', 'CUT Ixias', 0,
   jsonb_build_object('tries', 2, 'verified_tries_in_available_match_reports', 2, 'season_total_complete', false,
     'match_report_scope', 'CUT v UJ; CUT v UFS Shimlas; CUT v UWC; UCT v CUT'),
   'https://www.varsitycup.co.za/news/matchday-wrap-ikey-tigers-stun-maties-in-milestone-match', now()),
  ('ecfa7e4b-cc49-4e78-8ada-280701fa3ff6', 'Albertus Venter', 'CUT Ixias', 0,
   jsonb_build_object('tries', 1, 'verified_tries_in_available_match_reports', 1, 'season_total_complete', false,
     'match_report_scope', 'CUT v UJ; CUT v UFS Shimlas; CUT v UWC; UCT v CUT'),
   'https://www.varsitycup.co.za/news/matchday-wrap-ikey-tigers-stun-maties-in-milestone-match', now())
on conflict (competition_id, player_name, team_name) do update
set statistics = public.competition_player_statistics.statistics || excluded.statistics,
    source_url = excluded.source_url,
    source_checked_at = excluded.source_checked_at;
