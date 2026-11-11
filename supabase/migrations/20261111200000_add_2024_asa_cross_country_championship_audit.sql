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
   $desc$Event date, venue and provisional-final results verified from Athletics Gauteng North and Central Gauteng Athletics result archives. The championship was held on 7 September 2024 at Vaal University of Technology, Isaac Steyl Stadium, Vanderbijlpark. Official individual results are organised by provincial federation code (including AFS for Free State), not university/club. The overall provincial medal table ranks AFS third with 30 total medals (7 team gold, 3 team silver, 7 team bronze; 4 individual gold, 5 individual silver, 4 individual bronze). These are provincial federation totals and must not be represented as CUT team medals or CUT athlete results.

Additional individual-sheet review: the women's 23–4km sheet lists Karabo Mokalodise 48th in 18:13 for AFS; the Senior Women's 4km sheet lists Thobile Mkhize 17th in 15:36 for AFS; the Women's 50–4km sheet lists Pulane Motshabi 19th in 18:25 for AFS. These entries confirm provincial participation only, not CUT affiliation. Exact case-insensitive, trimmed-name checks against existing public.competition_player_statistics returned zero matches for these three names. The public.athletes registry is empty. No individual or team result has been imported.

CUT attribution audit: AFS/Free State representation alone is insufficient evidence of CUT membership. Under the CUT database name-matching rule, no athlete is attributed without an exact existing CUT athlete record and independent confirmation of CUT affiliation. No team medal or standing is attributed to CUT.

Sources: AGN 2024 ASA provisional-final results archive https://agn.co.za/2024-asa-cross-country-championships-provisional-final-results/ ; full individual results PDF https://centralgautengathletics.co.za/wp-content/uploads/2024/10/2024-ASA-CROSS-COUNTRY-FINAL-RESULTS-Provisional.pdf ; team medals PDF https://agn.co.za/wp-content/uploads/2024/09/2024-ASA-CROSS-COUNTRY-Team-Medals-Provisional-Final.pdf ; overall provincial medal table https://agn.co.za/wp-content/uploads/2024/09/2024-ASA-CROSS-COUNTRY-Overall-Provisional-Final.pdf$desc$,
   'completed')
on conflict (id) do update set
  name=excluded.name, season=excluded.season, start_date=excluded.start_date,
  end_date=excluded.end_date, venue=excluded.venue,
  description=excluded.description, status=excluded.status;
