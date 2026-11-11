-- Add scorer breakdowns for three further 2021 CUT Ixias Varsity Cup fixtures.
update public.competition_matches
set statistics = coalesce(statistics,'{}'::jsonb) || jsonb_build_object(
 'scorers',jsonb_build_object(
  'NMU Madibaz',jsonb_build_array('Tembekile Boltina','Duan du Plessis'),
  'CUT Ixias',jsonb_build_array('Janus Venter','Janus Venter','Ricoman Titus','Cohen Jasper','Cohen Jasper','Niell Stannard','Niell Stannard')
 ),
 'scoring_source','https://www.ofm.co.za/article/rugby/303320/ixias-continue-to-impress-in-varsity-cup',
 'scoring_data_status','Published match report; CUT seven-try scorer list'
)
where id='ee51725a-bb9f-40c6-8d3f-e778e458a4cf';

update public.competition_matches
set statistics = coalesce(statistics,'{}'::jsonb) || jsonb_build_object(
 'scorers',jsonb_build_object(
  'Wits',jsonb_build_array('Justin Brandon'),
  'CUT Ixias',jsonb_build_array('Janus Venter','Janus Venter','Luvuyo Ndevu')
 ),
 'scoring_source','https://rugby365.com/tournaments/varsity-cup/news-varsity-cup/uj-win-at-last/',
 'scoring_data_status','Published match report; CUT scorer list'
)
where id='2cb0abd2-3930-4ca4-8831-4f8473493679';

update public.competition_matches
set statistics = coalesce(statistics,'{}'::jsonb) || jsonb_build_object(
 'scorers',jsonb_build_object(
  'UCT Ikey Tigers',jsonb_build_array('William Rose','Athi Gazi','Athi Gazi','Athi Gazi','Rethabile Louw','Rethabile Louw','Devon Arendse','Le Roux Malan','Neil Otto','Gary Porter','Josh van Vuuren','Liam Kloosman'),
  'CUT Ixias',jsonb_build_array('Hans Terblanche')
 ),
 'scoring_source','https://www.news24.com/sport/rugby/varsitycup/wrap-varsity-cup-round-5-20210426',
 'scoring_data_status','Published match report; CUT try scorer identified'
)
where id='3ec3f0c5-3ef9-44e6-a06f-6b4fd8cb5352';