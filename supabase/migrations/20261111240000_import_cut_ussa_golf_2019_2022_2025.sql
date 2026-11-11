-- Import verified CUT USSA Golf competition history.
-- Team placings are sourced from CUT institutional publications.
-- Individual golfer rows are deliberately omitted unless matched to the
-- existing CUT competition-player registry under the strict exact-name rule.

insert into public.competitions
  (id, sport_id, name, season, start_date, end_date, venue, description, status)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2019a5a00001',
   (select id from public.sports where name = 'Golf' limit 1),
   'USSA Golf Championships',
   '2019', '2019-07-01', '2019-07-07',
   'Nelson Mandela University, Gqeberha, South Africa',
   'CUT Golf participated in the USSA National Golf Tournament hosted by Nelson Mandela University from 1–7 July 2019 and was promoted to the A Section. The available CUT annual-report source confirms participation and promotion but does not provide a final numeric team placing or individual scores. Source: CUT Annual Report 2019, sport highlights https://fliphtml5.com/imhpe/kzng/Annual_Report._2019/',
   'completed'),
  ('a43e3a9b-7c4e-4d7e-9f7c-2022a5a00001',
   (select id from public.sports where name = 'Golf' limit 1),
   'USSA Golf Tournament',
   '2022', '2022-04-11', '2022-04-13',
   'Paarl Golf Club, Western Cape, South Africa',
   'CUT Golf finished 3rd overall in the USSA Golf Tournament, earning the team bronze medal. CUT captain Mojalefa Xaba finished 4th in the individual standings. The official CUT news article gives the event dates as 11–13 April 2022; the 2022 annual-report narrative gives a broader 10–15 April period, so the official CUT news article is used for the event dates. Xaba’s individual result is retained in this event description only because his name does not match an existing player record in the CUT competition-player registry; no individual statistics row has been created. Sources: CUT News, 19 April 2022 https://www.cut.ac.za/news/cut-golf-team-places-3rd-overall-in-ussa-golf ; CUT Annual Report 2022, page 281 https://cms.cut.ac.za/Files/Froala/a331d2a8-5ca9-493d-85dd-a942791a1a64.pdf',
   'completed'),
  ('a43e3a9b-7c4e-4d7e-9f7c-2025b5a00001',
   (select id from public.sports where name = 'Golf' limit 1),
   'USSA Golf Tournament',
   '2025', '2025-12-01', '2025-12-05',
   'Nelson Mandela University, Gqeberha, South Africa',
   'CUT Golf participated in the USSA Golf Tournament hosted by Nelson Mandela University from 1–5 December 2025 and achieved 2nd position overall. The available CUT annual-report source confirms the team placing but does not provide matchplay/strokeplay breakdowns, golfer names or individual scores. No individual statistics are inferred. Source: CUT Annual Report 2025, section 11.8, page 34 https://cms.cut.ac.za/Files/Froala/e1338b1b-1a2c-4dd1-8867-270ca64cbf93.pdf',
   'completed')
on conflict (id) do update set
  sport_id=excluded.sport_id,name=excluded.name,season=excluded.season,
  start_date=excluded.start_date,end_date=excluded.end_date,
  venue=excluded.venue,description=excluded.description,status=excluded.status;

insert into public.competition_standings
  (competition_id, team_name, group_name, position, source_url, source_checked_at)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2022a5a00001',
   'CUT Golf', 'Overall Team Standing', 3,
   'https://www.cut.ac.za/news/cut-golf-team-places-3rd-overall-in-ussa-golf',
   now()),
  ('a43e3a9b-7c4e-4d7e-9f7c-2025b5a00001',
   'CUT Golf', 'Overall Team Standing', 2,
   'https://cms.cut.ac.za/Files/Froala/e1338b1b-1a2c-4dd1-8867-270ca64cbf93.pdf',
   now())
on conflict (competition_id, team_name, group_name) do update set
  position=excluded.position, source_url=excluded.source_url,
  source_checked_at=excluded.source_checked_at, updated_at=now();
