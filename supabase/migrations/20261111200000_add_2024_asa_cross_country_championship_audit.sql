-- Record 2024 ASA Cross Country Championships metadata and CUT attribution audit.
-- ASA results are recorded by provincial federation, not university; do not
-- infer CUT affiliation from Free State (AFS) or athlete names alone.
insert into public.competitions
  (id, sport_id, name, season, start_date, end_date, venue, description, status)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2024a5a00001',
   (select id from public.sports where name = 'Athletics & Cross Country' limit 1),
   'ASA South African Cross Country Championships',
   '2024', '2024-09-07', '2024-09-07',
   'Vaal University of Technology, Isaac Steyl Stadium, Vanderbijlpark, Gauteng, South Africa',
   'Event date, venue and provisional-final results verified from Athletics Gauteng North result archive. The official results are organised by provincial federation code (including AFS for Free State), not university/club. The overall provincial medal table ranks AFS third with 30 total medals (7 team gold, 3 team silver, 7 team bronze; 4 individual gold, 5 individual silver, 4 individual bronze). These are provincial federation totals and must not be represented as CUT team medals or CUT athlete results.\n\nCUT attribution audit: no individual or team result is imported because the published ASA result sheets identify provincial federation affiliation rather than CUT university affiliation. AFS/Free State representation alone is insufficient evidence of CUT membership. Under the CUT database name-matching rule, no athlete is attributed without an exact existing CUT athlete record and independent confirmation of CUT affiliation.\n\nSources: AGN 2024 ASA provisional-final results archive https://agn.co.za/2024-asa-cross-country-championships-provisional-final-results/ ; official male individual results https://agn.co.za/wp-content/uploads/2024/09/2024-ASA-CROSS-COUNTRY-Individual-Male-Provisional-Final.pdf ; official overall provincial medal table https://eolstoragewe.blob.core.windows.net/wm-11330-cmsimages/2024ASACROSSCOUNTRY-Overall%28ProvisionalFinal%29.pdf',
   'completed')
on conflict (id) do update set
  name=excluded.name, season=excluded.season, start_date=excluded.start_date,
  end_date=excluded.end_date, venue=excluded.venue,
  description=excluded.description, status=excluded.status;
