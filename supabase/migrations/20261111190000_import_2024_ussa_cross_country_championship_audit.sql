-- Record the 2024 USSA Cross Country Championships event and audit outcome.
-- Do not create athlete result rows unless the athlete already exists in the CUT
-- athlete database and the official result independently confirms the placing.
insert into public.competitions
  (id, sport_id, name, season, start_date, end_date, venue, description, status)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2024c0550001',
   (select id from public.sports where name = 'Athletics & Cross Country' limit 1),
   'USSA Cross Country Championships',
   '2024', '2024-09-13', '2024-09-14',
   'Nelson Mandela University, South Campus, Gqeberha, Eastern Cape, South Africa',
   'Event date and venue verified by Athletics South Africa event listing and University of Cape Town Athletics Club archive. The competition was held 13–14 September 2024 at Nelson Mandela University, Gqeberha. Official result PDFs are linked from the UCT Athletics Club 2024 cross-country archive and include individual 4km/10km races, team competitions and short/long relays.\n\nCUT athlete matching audit: the public.athletes table currently contains zero registered athlete profiles. Therefore no individual results can be safely attributed to existing CUT athlete profiles, and no new athlete profiles or individual result rows have been created. The available 4km women results and long mixed relay results reviewed do not identify a CUT team entry; the long mixed relay published top-eight places are UPT, UJ, NWU Potch, UFS, TUT, Fort Hare, UWC and NMU. No CUT team placing is established by those published top-eight results. Other individual/team PDF files are linked in the source archive; where their contents could not be retrieved in this audit, no claim of a complete CUT absence is made.\n\nSources: ASA event listing https://athleticssa.org.za/Events/Details?id=198 ; UCT Athletics Club archive https://sport.uct.ac.za/athletics-club/cross-country-2024 ; female 4km result PDF https://sport.uct.ac.za/media/640488 ; long mixed relay PDF https://sport.uct.ac.za/media/640511',
   'completed')
on conflict (id) do update set
  name=excluded.name, season=excluded.season, start_date=excluded.start_date,
  end_date=excluded.end_date, venue=excluded.venue,
  description=excluded.description, status=excluded.status;
