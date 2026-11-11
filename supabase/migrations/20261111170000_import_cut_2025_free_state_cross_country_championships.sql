-- Import verified CUT results from the 2025 Free State Cross Country Championships.
insert into public.competitions
  (id, sport_id, name, season, start_date, end_date, venue, description, status)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2025f5c00001',
   (select id from public.sports where name = 'Athletics & Cross Country' limit 1),
   'Free State Cross Country Championships',
   '2025', '2025-08-09', '2025-08-09',
   'UFS Sports Grounds, Bloemfontein, Free State, South Africa',
   $desc$CUT athlete results verified against the official Bloemfontein Cross Country championship results PDF for Saturday 9 August 2025. The published results list CUT as the club for the athletes below.

WOMEN 23 — 4 KM
Karabo Mokalodise — 7th, 18:33
Tsakynea Baloi — 17th, 24:59

MEN 23 — 4 KM
Ubabalwe Ndima — 5th, 13:26
Mmiseni Ngcobo — 7th, 13:45
Thamsanqa Mbeba — 12th, 14:05
Kamvu Nuba — 13th, 14:08
Mehluli September — 35th, 15:51

SENIOR WOMEN — 4 KM
Jayme-Sue Vermaas — 2nd, 17:05
Nomsa Mnisi — 5th, 19:36

SENIOR MEN — 4 KM
Shalton Kok — 23rd, 14:54
Karabo Rancho — 25th, 15:15
Lehlohonolo Khoanyane — 30th, 16:24

MEN 35–39
Paul Mmgomezulu — 6th, 29:44

MEN 45–49
Lebogang Mogongoa — 6th, 36:40

SENIOR MEN — 2 KM
Katleho Maema — 27th, 8:52

SENIOR WOMEN — 2 KM
Thenjiwe Sibisi — 9th, 9:20

This is a record of verified CUT athlete placings in the published results, not a full province-wide medal table or team championship score. Results are stored in the competition description because the current athlete-statistics table is designed around hockey scoring.

Source: https://www.bfnxcountry.co.za/index.php/results/fs-championships?download=336%3A2025-fs-xc-champs-results-perage
Event date and UFS grounds cross-checked against the official 2025 championship information: https://bfnxcountry.co.za/index.php/downloads/category/6-fs-championships?download=331%3A2025-free-state-championships-info$desc$,
   'completed')
on conflict (id) do update set
  name = excluded.name, season = excluded.season,
  start_date = excluded.start_date, end_date = excluded.end_date,
  venue = excluded.venue, description = excluded.description, status = excluded.status;
