do $$
declare f2022 uuid; n2025 uuid; n2026 uuid; r2025 uuid;
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
  values ('1bcb39e2-39b2-4b54-9c7e-221f43cdd2e6','USSA Netball Championships','2025','South Africa','CUT finished in the top eight at the 2025 USSA Netball Championships, qualifying for the university''s Varsity Netball debut in 2026.','completed')
  returning id into n2025;

  insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
  values
  (n2025,'CUT','{"final_position_band":"Top 8","qualification_for":"Varsity Netball 2026","qualification_achieved":true}'::jsonb,'https://supersport.com/rugby/news/9ef7e578-2cfb-4413-9315-d71a89dc3e3a/varsity-netball-returns-as-cut-makes-debut-while-maties-chase-centenary-glory');

  insert into public.competitions (sport_id,name,season,venue,description,status)
  values ('1bcb39e2-39b2-4b54-9c7e-221f43cdd2e6','USSA Netball Championships','2026','South Africa','CUT finished 5th at the 2026 USSA Netball Championships, securing another Varsity Netball appearance for 2027.','completed')
  returning id into n2026;

  insert into public.competition_team_statistics (competition_id,team_name,statistics,source_url)
  values
  (n2026,'CUT','{"final_position":5,"qualification_for":"Varsity Netball 2027","qualification_achieved":true}'::jsonb,'https://supersport.com/rugby/news/9ef7e578-2cfb-4413-9315-d71a89dc3e3a/varsity-netball-returns-as-cut-makes-debut-while-maties-chase-centenary-glory');

  select id into r2025 from public.competitions where sport_id='83ddd3ad-ceef-4855-8e37-1303e388f58d' and name='FNB Varsity Cup' and season='2025' limit 1;
  insert into public.competition_standings
  (competition_id,team_name,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,bonus_points,points,source_url,source_checked_at)
  values
  (r2025,'CUT Ixias','League Table',6,7,3,0,4,140,300,-160,null,11,'https://en.wikipedia.org/wiki/2025_Varsity_Cup',now())
  on conflict (competition_id,team_name,group_name) do update set
   position=excluded.position,played=excluded.played,won=excluded.won,drawn=excluded.drawn,lost=excluded.lost,
   scored=excluded.scored,conceded=excluded.conceded,points_difference=excluded.points_difference,
   bonus_points=excluded.bonus_points,points=excluded.points,source_url=excluded.source_url,
   source_checked_at=now(),updated_at=now();

  update public.competitions
  set description=description||' UJ won the 2026 championship with a 56-44 final victory over NWU Eagles.'
  where sport_id='1bcb39e2-39b2-4b54-9c7e-221f43cdd2e6' and name='Varsity Netball' and season='2026';
end $$;