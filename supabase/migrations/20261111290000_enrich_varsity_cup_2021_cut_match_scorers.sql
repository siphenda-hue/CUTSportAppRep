-- Enrich two 2021 CUT Varsity Cup match records with scorer lists from published reports.
update public.competition_matches
set statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
  'scorers', jsonb_build_object(
    'UWC', jsonb_build_array('Jason Alexander','Jason Alexander','Tinotenda Mavesere','Aydon Topley','Aydon Topley','Branden de Kock','Bronlee Mouries','Conwill Conradie'),
    'CUT Ixias', jsonb_build_array('Janus Venter','Ricoman Titus','Cohen Jasper')
  ),
  'scoring_source','https://www.varsitycup.co.za/news/matchday-wrap-superb-uwc-stay-in-semi-final-hunt-ikeys-remain-unbeaten',
  'scoring_data_status','Published match report scorer list; CUT player scorers identified'
)
where id='5ebd2354-cbff-46ba-9b20-2b1324800a04';

update public.competition_matches
set statistics = coalesce(statistics, '{}'::jsonb) || jsonb_build_object(
  'scorers', jsonb_build_object(
    'CUT Ixias', jsonb_build_array('Brendon Fortuin','Janus Venter','Janus Venter','Heino Bezuidenhout','Xander Botha'),
    'NWU Eagles', jsonb_build_array('Jeandré Leonard','Jeandré Leonard','Ruben Dreyer')
  ),
  'scoring_source','https://rugby365.com/tournaments/varsity-cup/news-varsity-cup/former-boks-eagles-secure-varsity-cup-semi-final-spot/',
  'scoring_data_status','Published match report scorer list; CUT player scorers identified'
)
where id='2932ddb8-c835-4fc8-a197-a2772f96d82c';