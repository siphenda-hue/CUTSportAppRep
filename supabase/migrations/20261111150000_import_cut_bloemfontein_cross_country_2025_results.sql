-- Record verified 2025 Bloemfontein Cross Country League participation/results for CUT.
-- Official Bloemfontein XC result PDFs:
-- League 1 (9 May 2025): https://www.bfnxcountry.co.za/index.php/results/league-1?download=307%3Aleague-1-2025-results-perschool-club
-- League 6 (13 June 2025): https://bfnxcountry.co.za/index.php/results/league-6?download=327%3Aleague-6-2025-results-perschool-club

insert into public.competitions (
  sport_id, name, season, start_date, end_date, venue, description, status
)
select
  'f61de6a2-cbb9-4ffb-96c7-84a0e98023ca'::uuid,
  'Bloemfontein Cross Country League',
  '2025',
  null,
  null,
  'Bloemfontein, Free State, South Africa',
  E'CUT results verified from published Bloemfontein Cross Country League PDFs. This record summarises two retrieved fixtures; it is not a complete season leaderboard.\n\nLEAGUE 1 — 9 May 2025\nMen 23–4km: Mmiseni Ngcobo 1st (12:40); Themba Moloi 3rd (12:56); Kamvu Nuba 4th (12:56); Ubabalwe Ndima 7th (13:21); Thamsanqa Mbeba 8th (13:38); Mehluli September 11th (14:34); Philip Erasmus 23rd (18:57).\nMen 45–49: Lebogang Mogongoa 2nd (40:06). Men 50–54: Fusitive Motshabi 4th (46:06). Senior Men 4km: Shaldon Kok 8th (13:42). Senior Women 4km: Thenjiwe Sibisi 5th (19:24); Nomsa Mnisi 6th (20:44). Women 23–4km: Karabo Mokalodise 3rd (18:23). Women 50–54: Leana Esterhuizen 2nd (19:32).\n\nLEAGUE 6 — 13 June 2025\nSenior Men 2km: Karabo Rancho 5th (7:34). Junior Women 6km: Matumelo Makama 6th (31:04). Men 23–4km: Thamsanqa Mbeba 8th (15:04); Mehluli September 12th (15:36). Senior Women 4km: Nomsa Mnisi 3rd (20:10). Women 23–4km: Karabo Mokalodise 4th (18:24).\n\nThe league result PDFs identify CUT as the club. Results are preserved exactly as published; no cumulative season ranking or overall team score has been inferred.',
  'completed'
where not exists (
  select 1 from public.competitions
  where sport_id = 'f61de6a2-cbb9-4ffb-96c7-84a0e98023ca'::uuid
    and name = 'Bloemfontein Cross Country League'
    and season = '2025'
);
