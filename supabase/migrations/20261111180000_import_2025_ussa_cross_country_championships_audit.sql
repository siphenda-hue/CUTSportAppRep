-- Record the 2025 USSA Cross Country Championships / ASA trials event context.
-- Individual CUT results are not imported because the accessible event portal could
-- not be reliably reconciled to CUT club affiliation.
insert into public.competitions
  (id, sport_id, name, season, start_date, end_date, venue, description, status)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2025u55a00001',
   (select id from public.sports where name = 'Athletics & Cross Country' limit 1),
   'USSA Cross Country Championships',
   '2025', '2025-10-03', '2025-10-04',
   'Tshwane University of Technology, Pretoria, Gauteng, South Africa',
   'Event context verified from Athletics South Africa coverage dated 3 October 2025 and University of Pretoria coverage dated 7–8 October 2025. The USSA cross-country competition was held alongside the ASA Cross Country Trials at TUT in Tshwane. ASA reports the senior 10km and 2km trial winners; UP reports Tuks as overall USSA champions after winning four races.\n\nCUT participation and CUT-specific individual results have not been verified in the accessible result material. The ASA results portal provides event-level men’s and women’s result sections, but the available page extraction did not expose a reliably attributable CUT club list. No athlete placings or team ranking have therefore been invented or imported.\n\nSources: ASA news https://athleticssa.org.za/Newsart/Details?id=341 ; ASA results portal EventID 61 https://athleticssa.org.za/XCResultX/ResultListDet?EventID=61&EventType=Cross+Country&Eventname=USSA+Cross+Country+Championships ; UP report https://www.up.ac.za/news/tuks-are-ussa-cross-country-champions',
   'completed')
on conflict (id) do update set
  name=excluded.name, season=excluded.season, start_date=excluded.start_date,
  end_date=excluded.end_date, venue=excluded.venue,
  description=excluded.description, status=excluded.status;
