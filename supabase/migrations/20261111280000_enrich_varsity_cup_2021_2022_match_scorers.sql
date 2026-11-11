-- Enrich archived CUT Varsity Cup match records with verified scorer details.
-- This is metadata-only: existing scores and season aggregates are deliberately preserved.

update public.competition_matches
set statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
  'scorers', jsonb_build_object(
    'CUT Ixias', jsonb_build_array('Johannes Terblanche','Brendon Fortuin','Janus Venter','Ulrich Stander','Cohen Jasper','Cohen Jasper'),
    'UJ', jsonb_build_array('Prince Nkabinde')
  ),
  'player_that_rocks', 'Janu Botha',
  'scoring_source', 'https://iol.co.za/sport/rugby/2021-04-05-cut-power-past-uj-tuks-surge-sinks-wits/'
), source_checked_at = now()
where id = 'cf7eb9e0-f746-4027-9b28-4d58a9cd1984';

update public.competition_matches
set statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
  'scorers', jsonb_build_object(
    'CUT Ixias', jsonb_build_array('Charles Williams','Hans Terblanche','Neill Stannard'),
    'UFS Shimlas', jsonb_build_array('William Moffat','William Moffat','Johannes Klinck')
  ),
  'player_that_rocks', 'Charles Williams',
  'scoring_source', 'https://www.cut.ac.za/news/fnb-cut-ixias-claim-third-consecutive-free-state-derby-in-varsity-cup'
), source_checked_at = now()
where id = '8161ee67-59be-4a62-b84f-47fc9e325eb2';

update public.competition_matches
set statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
  'scorers', jsonb_build_object(
    'CUT Ixias', jsonb_build_array('Hans Terblanche','Heino Bezuidenhout','Cohen Jasper'),
    'Maties', jsonb_build_array('Lian du Toit')
  ),
  'player_that_rocks', 'Zinedine Booysen',
  'scoring_source', 'https://www.varsitycup.co.za/news/matchday-wrap-cut-shock-maties-eagles-edge-wits'
), source_checked_at = now()
where id = '2492fedc-4ee0-4da8-a26a-659b16cb623c';

update public.competition_matches
set statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
  'scorers', jsonb_build_object(
    'CUT Ixias', jsonb_build_array('Janus Venter','Janus Venter','Janus Venter','Janus Venter','Luvoyo Ndevu','Cohen Jasper'),
    'UP Tuks', jsonb_build_array('Louritz van der Schyff','Andre van der Merwe','Eduan Lubbe','Zandre Kruger','Penalty Try','Tharquinn Manuel')
  ),
  'player_that_rocks', 'Xander Botha',
  'scoring_source', 'https://www.varsitycup.co.za/news/matchday-wrap-cut-ixias-nwu-eagles-to-meet-in-quarter-final-clash'
), source_checked_at = now()
where id = 'c68505dd-8c22-43b5-a938-d794ec00c96e';

update public.competition_matches
set statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
  'scorers', jsonb_build_object(
    'CUT Ixias', jsonb_build_array('Tiaan Drotske','Ulrich Stander','Teboho Rampai','Jacquin van Wyk','Jan Kotze','Penalty Try'),
    'UJ', jsonb_build_array('Johannes Terblanche','Johannes Terblanche','Philip Apea-Adu','Brendon Pawson','Hloni Mphuthi','CJ Masuku')
  ),
  'score_source_discrepancy', jsonb_build_object(
    'database_score', 'CUT Ixias 44-44 UJ',
    'CUT_published_report_score', 'CUT Ixias 42-44 UJ',
    'note', 'CUT published match report and stored match score differ; score intentionally not overwritten pending authoritative reconciliation.'
  ),
  'scoring_source', 'https://www.cut.ac.za/news/varsity-cup-fnb-cut-met-fnb-uj-in-a-thrilling'
), source_checked_at = now()
where id = 'c4ca6a82-9499-4a55-b15c-324f94865b7a';

update public.competition_matches
set statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
  'scorers', jsonb_build_object(
    'CUT Ixias', jsonb_build_array('Luvuyo Ndevu','Penalty Try','Teboho Rampai'),
    'UFS Shimlas', jsonb_build_array('Thabang Mahlasi','William Moffat','Janco van Heyningen','Lourens Oosthuizen','Asanda Kunene','Asanda Kunene','Lohan Potgieter','Nqobani Dlamini')
  ),
  'scoring_source', 'https://iol.co.za/sport/rugby/2022-02-28-watch-ufs-shimlas-thump-cut-ixias-48-27-in-varsity-cup/'
), source_checked_at = now()
where id = 'af87e12f-f708-4d04-b1c0-ee1b6a53d29f';

update public.competition_matches
set statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
  'scorers', jsonb_build_object(
    'CUT Ixias', jsonb_build_array('Matthew Sekele','Matthew Sekele','Jacquin van Wyk','Septimus Derkesen','Albertus Venter'),
    'UWC', jsonb_build_array('Aydon Topley','Haniel du Toit','Haniel du Toit','Romuald Ntumba','Mauritz Swart','Nicholas Chipanje')
  ),
  'scoring_source', 'https://www.varsitycup.co.za/news/matchday-wrap-ikey-tigers-stun-maties-in-milestone-match'
), source_checked_at = now()
where id = '495c0185-4527-4b1b-affb-87a6f09c1e46';

update public.competition_matches
set statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
  'scorers', jsonb_build_object(
    'CUT Ixias', jsonb_build_array('Jan Kotze','Matthew Sekele','Septimus Derkesen','Luvuyo Ndevu'),
    'UCT Ikey Tigers', jsonb_build_array('Imad Khan','Imad Khan','Mika Schubert','Suleiman Hartzenberg','Suleiman Hartzenberg')
  ),
  'scoring_source', 'https://www.cut.ac.za/news/cut-ixias-stay-in-varsity-cup-despite-winless'
), source_checked_at = now()
where id = '531cc9a7-75ad-4ce4-9e12-8599d57fb139';

-- Explicitly keep the 2021 aggregate totals unchanged: Janus Venter 12 tries,
-- Cohen Jasper 7 tries, and Charles Williams 71 points remain the published season totals.
