-- Record the 2025 ASA Cross Country Championships event metadata.
-- No CUT athlete placings are imported: the accessible ASA result portal identifies
-- athletes by province, not club, and no independently verified CUT-to-entry match
-- was found during this audit.
insert into public.competitions
  (id, sport_id, name, season, start_date, end_date, venue, description, status)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2025asa00001',
   (select id from public.sports where name = 'Athletics & Cross Country' limit 1),
   'ASA South African Cross Country Championships',
   '2025', '2025-09-06', '2025-09-06',
   'Kees Taljaard Stadium, Middelburg, Mpumalanga, South Africa',
   'Event metadata verified against the official ASA 2025 fixtures list and Athletics Gauteng North Circular 68 of 2025. The event took place on 6 September 2025 at Kees Taljaard Stadium, Middelburg.\n\nCUT participation and individual CUT athlete placings have not been verified in this import. The accessible ASA results portal identifies athletes by province rather than club; provincial affiliation alone is not sufficient evidence to attribute a result to CUT. No athlete statistics or team placing have therefore been invented or imported.\n\nSources: https://athleticssa.org.za/SportsInfo/2025ASAFixture.pdf ; https://agn.co.za/wp-content/uploads/2025/08/CIRCULAR-68-OF-2025-ASA-CROSS-COUNTRY-CHAMPIONSHIPS.pdf ; ASA results portal EventID 265: https://athleticssa.org.za/XCResultX/ResultListDet?EventID=265&EventType=Cross+Country&Eventname=ASA+Cross+Country+Championships+',
   'completed')
on conflict (id) do update set
  name = excluded.name, season = excluded.season,
  start_date = excluded.start_date, end_date = excluded.end_date,
  venue = excluded.venue, description = excluded.description,
  status = excluded.status;
