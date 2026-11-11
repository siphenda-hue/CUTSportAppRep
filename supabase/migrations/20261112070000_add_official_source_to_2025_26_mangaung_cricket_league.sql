-- Attach the directly accessible CUT 2025/26 Annual Report source to the existing Mangaung Cricket League record.
-- The report confirms participation and dates only; no standings or match statistics are inferred.
update public.competitions
set description = 'CUT Cricket participated in the Mangaung Cricket League from September 2025 until 25 April 2026. The CUT annual report confirms participation but does not state final placing, match results or player statistics. No results or player figures are inferred. Official source: https://cms.cut.ac.za/Files/Froala/e1338b1b-1a2c-4dd1-8867-270ca64cbf93.pdf'
where id = 'a43e3a9b-7c4e-4d7e-9f7c-2025c5a00001'
  and name = 'Mangaung Cricket League'
  and season = '2025/26';
