-- Import CUT's 2014 USSA hockey team placements from the June 2014 Gratia magazine.
-- Dates, venue, opponents (except the women's DUT draw), and match scores are not published in the source.

insert into public.competitions (
  id, sport_id, name, season, start_date, end_date, venue, description, status
)
values
(
  'b8142014-0000-4000-8000-000000000001',
  'cc6888d8-dd80-470d-9046-2bddf1a6b19a',
  'USSA Hockey Tournament — Men',
  '2014',
  null,
  null,
  null,
  'CUT men finished 4th out of six teams in the hockey tournament reported in CUT''s June 2014 Gratia magazine. The report does not specify the tournament dates, venue, match results, or section for the men. Source: https://www.cut.ac.za/wp-content/uploads/2013/04/Gratia-June-2014.pdf',
  'completed'
),
(
  'b8142014-0000-4000-8000-000000000002',
  'cc6888d8-dd80-470d-9046-2bddf1a6b19a',
  'USSA Hockey Tournament — Women C-Section',
  '2014',
  null,
  null,
  null,
  'CUT women finished 2nd out of six teams in the C-Section. CUT won four of five matches and drew against Durban University of Technology (DUT). The source does not provide the other opponents, scores, dates, or venue. Source: https://www.cut.ac.za/wp-content/uploads/2013/04/Gratia-June-2014.pdf',
  'completed'
)
on conflict (id) do nothing;
