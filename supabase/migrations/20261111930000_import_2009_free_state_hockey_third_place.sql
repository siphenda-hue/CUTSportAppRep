-- Import the verified 2009 Free State men's hockey championship result for CUT 1.
-- CUT finished third. The third-place match ended 4-4 before a 4-3 shoot-out
-- win for UFS Reds. The source does not publish the match date.
insert into public.competitions (id,sport_id,name,season,start_date,end_date,venue,description,status)
select 'b8092009-0000-4000-8000-000000000001','cc6888d8-dd80-470d-9046-2bddf1a6b19a','Free State Hockey Championship — Men','2009',null,null,'University of the Free State astro fields, Bloemfontein, South Africa','CUT 1 finished third in the 2009 Free State men’s hockey championship. In the third-place match, UFS Reds drew 4–4 with CUT 1 before winning the penalty shoot-out 4–3. The published report identifies CUT 1 as the third-place team but does not state the match date. Source: https://www.ufs.ac.za/humanities/News?NewsItemID=1491','completed'
where not exists (select 1 from public.competitions where sport_id='cc6888d8-dd80-470d-9046-2bddf1a6b19a' and season='2009' and name='Free State Hockey Championship — Men');

insert into public.competition_matches (id,competition_id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,source_url,statistics)
select gen_random_uuid(),'b8092009-0000-4000-8000-000000000001','ufs-reds-cut1-2009-third-place',null,'UFS Reds','CUT 1',4,4,'completed','Third-place match','https://www.ufs.ac.za/humanities/News?NewsItemID=1491',jsonb_build_object('shootout_home',4,'shootout_away',3,'shootout_winner','UFS Reds','source','UFS official report')
where not exists (select 1 from public.competition_matches where competition_id='b8092009-0000-4000-8000-000000000001' and source_match_id='ufs-reds-cut1-2009-third-place');
