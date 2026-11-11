-- Record CUT's 2014 Free State Cricket First Division title.
-- CUT's 2014 Annual Report confirms the second team won the First Division
-- and earned promotion to the Free State Super League for 2014/15.
-- Match totals and a complete points table were not published in the source;
-- the schema's non-null aggregate columns therefore remain at their defaults.

insert into public.competition_standings (
  competition_id, team_name, position, source_url
)
select
  'a43e3a9b-7c4e-4d7e-9f7c-2014c5a00001',
  'CUT Second Team — First Division champions',
  1,
  'https://www.cut.ac.za/wp-content/uploads/2013/04/CUT-Annual-Report-2014.pdf'
where not exists (
  select 1
  from public.competition_standings
  where competition_id='a43e3a9b-7c4e-4d7e-9f7c-2014c5a00001'
    and team_name='CUT Second Team — First Division champions'
);
