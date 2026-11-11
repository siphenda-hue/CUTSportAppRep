begin;

-- Add all additional individually named CUT try scorers confirmed by 2021 match reports.
insert into public.competition_player_statistics
  (competition_id, player_name, team_name, total_goals, statistics, source_url)
values
('1ad53068-df4f-4a64-8670-00dd76a869d3','Johannes Terblanche','CUT Ixias',1,
 jsonb_build_object('sport','Rugby Union','statistic_type','tries','tries',1,'total_tries',1,
 'match_breakdown',jsonb_build_object('Round 1',1),
 'source_name_variants','[]'::jsonb,'stat_scope','verified individual try scorers in available match reports; full-season completeness not established',
 'verification_status','source-verified','season_total_complete',false),
 'https://rugby365.com/tournaments/varsity-cup/news-varsity-cup/cut-powers-past-uj-tuks-surge-sinks-wits/'),
('1ad53068-df4f-4a64-8670-00dd76a869d3','Brendon Fortuin','CUT Ixias',2,
 jsonb_build_object('sport','Rugby Union','statistic_type','tries','tries',2,'total_tries',2,
 'match_breakdown',jsonb_build_object('Round 1',1,'Round 8',1),
 'source_name_variants','[]'::jsonb,'stat_scope','verified individual try scorers in available match reports; full-season completeness not established',
 'verification_status','source-verified','season_total_complete',false),
 'https://rugby365.com/tournaments/varsity-cup/news-varsity-cup/former-boks-eagles-secure-varsity-cup-semi-final-spot/'),
('1ad53068-df4f-4a64-8670-00dd76a869d3','Hans Terblanche','CUT Ixias',3,
 jsonb_build_object('sport','Rugby Union','statistic_type','tries','tries',3,'total_tries',3,
 'match_breakdown',jsonb_build_object('Round 3',1,'Round 5',1,'Round 6',1),
 'source_name_variants','[]'::jsonb,'stat_scope','verified individual try scorers in available match reports; full-season completeness not established',
 'verification_status','source-verified','season_total_complete',false),
 'https://www.varsitycup.co.za/news/matchday-wrap-cut-shock-maties-eagles-edge-wits'),
('1ad53068-df4f-4a64-8670-00dd76a869d3','Heino Bezuidenhout','CUT Ixias',2,
 jsonb_build_object('sport','Rugby Union','statistic_type','tries','tries',2,'total_tries',2,
 'match_breakdown',jsonb_build_object('Round 6',1,'Round 8',1),
 'source_name_variants','[]'::jsonb,'stat_scope','verified individual try scorers in available match reports; full-season completeness not established',
 'verification_status','source-verified','season_total_complete',false),
 'https://www.varsitycup.co.za/news/matchday-wrap-cut-shock-maties-eagles-edge-wits'),
('1ad53068-df4f-4a64-8670-00dd76a869d3','Luvuyo Ndevu','CUT Ixias',2,
 jsonb_build_object('sport','Rugby Union','statistic_type','tries','tries',2,'total_tries',2,
 'match_breakdown',jsonb_build_object('Round 4',1,'Round 7',1),
 'source_name_variants',jsonb_build_array('Luvoyo Ndevu'),
 'stat_scope','verified individual try scorers in available match reports; full-season completeness not established',
 'verification_status','source-verified','season_total_complete',false),
 'https://rugby365.com/tournaments/varsity-cup/news-varsity-cup/uj-win-at-last/'),
('1ad53068-df4f-4a64-8670-00dd76a869d3','Niell Stannard','CUT Ixias',3,
 jsonb_build_object('sport','Rugby Union','statistic_type','tries','tries',3,'total_tries',3,
 'match_breakdown',jsonb_build_object('Round 2',2,'Round 3',1),
 'source_name_variants',jsonb_build_array('Neill Stannard'),
 'stat_scope','verified individual try scorers in available match reports; full-season completeness not established',
 'verification_status','source-verified','season_total_complete',false),
 'https://www.ofm.co.za/article/rugby/303320/ixias-continue-to-impress-in-varsity-cup'),
('1ad53068-df4f-4a64-8670-00dd76a869d3','Ricoman Titus','CUT Ixias',2,
 jsonb_build_object('sport','Rugby Union','statistic_type','tries','tries',2,'total_tries',2,
 'match_breakdown',jsonb_build_object('Round 2',1,'Round 7',1),
 'source_name_variants','[]'::jsonb,'stat_scope','verified individual try scorers in available match reports; full-season completeness not established',
 'verification_status','source-verified','season_total_complete',false),
 'https://www.ofm.co.za/article/rugby/303320/ixias-continue-to-impress-in-varsity-cup'),
('1ad53068-df4f-4a64-8670-00dd76a869d3','Ulrich Stander','CUT Ixias',1,
 jsonb_build_object('sport','Rugby Union','statistic_type','tries','tries',1,'total_tries',1,
 'match_breakdown',jsonb_build_object('Round 1',1),
 'source_name_variants','[]'::jsonb,'stat_scope','verified individual try scorers in available match reports; full-season completeness not established',
 'verification_status','source-verified','season_total_complete',false),
 'https://rugby365.com/tournaments/varsity-cup/news-varsity-cup/cut-powers-past-uj-tuks-surge-sinks-wits/'),
('1ad53068-df4f-4a64-8670-00dd76a869d3','Xander Botha','CUT Ixias',1,
 jsonb_build_object('sport','Rugby Union','statistic_type','tries','tries',1,'total_tries',1,
 'match_breakdown',jsonb_build_object('Round 8',1),
 'source_name_variants','[]'::jsonb,'stat_scope','verified individual try scorers in available match reports; full-season completeness not established',
 'verification_status','source-verified','season_total_complete',false),
 'https://rugby365.com/tournaments/varsity-cup/news-varsity-cup/former-boks-eagles-secure-varsity-cup-semi-final-spot/');

-- Charles Williams scored one try in Round 3; retain his independently reported 71 tournament points.
update public.competition_player_statistics
set total_goals = 1,
    statistics = statistics || jsonb_build_object(
      'tries',1,'total_tries',1,'statistic_type','tries_and_points',
      'match_breakdown',jsonb_build_object('Round 3',1),
      'stat_scope','one match-reported try plus official tournament points leaderboard total',
      'verification_status','source-verified','season_total_complete',false
    )
where id = '6743b291-ceb9-499b-886b-2ca65b71331f';

commit;