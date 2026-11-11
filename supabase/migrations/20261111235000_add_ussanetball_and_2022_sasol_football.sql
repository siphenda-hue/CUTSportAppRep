do $$
declare f2022 uuid; n2025 uuid; n2026 uuid;
begin
  insert into public.competitions (sport_id,name,season,venue,description,status)
  values ('4c1ccd6f-3965-422a-ad25-19aaa2797f23','Sasol Women''s League — Free State','2022','Free State','CUT Ladies (Ixias FC) finished first in Stream A unbeaten, winning all 10 recorded matches with no losses. The team were crowned Free State provincial Sasol League champions and qualified for the national promotion play-offs in Polokwane in October 2022.','completed')
  returning id into f2022;

  insert into public.competition_standings
  (competition_id,team_name,group_name,position,played,won,drawn,lost,source_url,source_checked_at)
  values
  (f2022,'CUT Ladies (Ixias FC)','Stream A',1,10,10,0,0,'https://cms.cut.ac.za/Files/Froala/a331d2a8-5ca9-493d-85dd-a942791a1a64.pdf',now());

  insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
  values
  (f2022,'CUT Ladies (Ixias FC)','{"matches_played":10,"wins":10,"draws":0,"losses":0,"unbeaten":true,"stream":"A","stream_position":1,"provincial_champions":true,"national_promotion_playoffs_qualified":true,"national_playoffs_location":"Polokwane","national_playoffs_start":"2022-10-18"}'::jsonb,'https://cms.cut.ac.za/Files/Froala/a331d2a8-5ca9-493d-85dd-a942791a1a64.pdf');

  insert into public.competitions (sport_id,name,season,venue,description,status)
  values ('6c1bd7e1-bd32-4367-8270-d2d0d3c0f3b9','USSA Netball Championships','2025','South Africa','CUT finished in the top eight at the 2025 USSA Netball Championships, qualifying for the university''s Varsity Netball debut in 2026.','completed')
  returning id into n2025;

  insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
  values
  (n2025,'CUT','{"final_position_band":"Top 8","qualification_for":"Varsity Netball 2026","qualification_achieved":true}'::jsonb,'https://supersport.com/rugby/news/9ef7e578-2cfb-4413-9315-d71a89dc3e3a/varsity-netball-returns-as-cut-makes-debut-while-maties-chase-centenary-glory');

  insert into public.competitions (sport_id,name,season,venue,description,status)
  values ('6c1bd7e1-bd32-4367-8270-d2d0d3c0f3b9','USSA Netball Championships','2026','South Africa','CUT finished 5th at the 2026 USSA Netball Championships, securing another Varsity Netball appearance for 2027.','completed')
  returning id into n2026;

  insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
  values
  (n2026,'CUT','{"final_position":5,"qualification_for":"Varsity Netball 2027","qualification_achieved":true}'::jsonb,'https://supersport.com/rugby/news/9ef7e578-2cfb-4413-9315-d71a89dc3e3a/varsity-netball-returns-as-cut-makes-debut-while-maties-chase-centenary-glory');


end $$;