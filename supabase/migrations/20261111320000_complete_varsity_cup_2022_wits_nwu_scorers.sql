-- Complete the 2022 CUT vs Wits scorer list and preserve the NWU report's unnamed CUT try detail.
update public.competition_matches
set statistics=coalesce(statistics,'{}'::jsonb)||jsonb_build_object(
 'scorers',jsonb_build_object(
  'Wits',jsonb_build_array('Setshaba Mokoena','Azi Afrika'),
  'CUT Ixias',jsonb_build_array('Jacquin van Wyk','Tiaan Drotske','Kevin Strydom')
 ),
 'scoring_source','https://rugby365.com/tournaments/varsity-cup/news-varsity-cup/varsity-cup-shimlas-stun-maties/',
 'scoring_data_status','Published Round 2 wrap with full scorer list'
)
where id='57a8e130-adde-4562-9a1d-139293d37472';

update public.competition_matches
set statistics=coalesce(statistics,'{}'::jsonb)||jsonb_build_object(
 'scoring_summary',jsonb_build_object(
  'CUT Ixias','Two loose-maul tries; individual try scorers not named in the published NWU report',
  'NWU Eagles','Marvelous Mashimbyi scored the opening try; further NWU try scorers not individually detailed in the source'
 ),
 'scoring_source','https://news.nwu.ac.za/eagles-keep-door-semi-finals-open',
 'scoring_data_status','Partial published match report; CUT scored two loose-maul tries but player identities are not published'
)
where id='c0e7440e-deca-4b4a-8f81-046492967ac3';