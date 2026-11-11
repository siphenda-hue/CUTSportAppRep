-- Record CUT men's and women's hockey participation at the 2017 USSA tournament.
-- CUT's 2017 Annual Report confirms both teams participated. It does not provide
-- sections, dates, standings, match results or individual statistics.
insert into public.competitions (id,sport_id,name,season,start_date,end_date,venue,description,status)
select 'b8172017-0000-4000-8000-000000000001','cc6888d8-dd80-470d-9046-2bddf1a6b19a','USSA Men Hockey Tournament','2017',null,null,null,'CUT Men’s Hockey participated in the 2017 University Sports South Africa (USSA) Hockey Tournament. CUT’s 2017 Annual Report confirms participation but does not publish the tournament section, final position, match results or player statistics. No scores or placings are asserted. Source: https://cms.cut.ac.za/Files/Froala/db266cab-08bd-4197-8f56-f9c8710f1a85.pdf','completed'
where not exists (select 1 from public.competitions where sport_id='cc6888d8-dd80-470d-9046-2bddf1a6b19a' and season='2017' and name='USSA Men Hockey Tournament');

insert into public.competitions (id,sport_id,name,season,start_date,end_date,venue,description,status)
select 'b8172017-0000-4000-8000-000000000002','cc6888d8-dd80-470d-9046-2bddf1a6b19a','USSA Women Hockey Tournament','2017',null,null,null,'CUT Women’s Hockey participated in the 2017 University Sports South Africa (USSA) Hockey Tournament. CUT’s 2017 Annual Report confirms participation but does not publish the tournament section, final position, match results or player statistics. No scores or placings are asserted. Source: https://cms.cut.ac.za/Files/Froala/db266cab-08bd-4197-8f56-f9c8710f1a85.pdf','completed'
where not exists (select 1 from public.competitions where sport_id='cc6888d8-dd80-470d-9046-2bddf1a6b19a' and season='2017' and name='USSA Women Hockey Tournament');
