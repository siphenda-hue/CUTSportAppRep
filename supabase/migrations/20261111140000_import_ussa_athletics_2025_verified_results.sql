-- Import verified CUT athlete performances from the 2025 USSA Track & Field Championships.
-- Sources: https://backtrack.co.za/2025/05/06/full-results-ussa-track-and-field-championships/
-- Event metadata cross-check: https://worldathletics.org/competition/calendar-results/results/7219517

insert into public.competitions (
  sport_id, name, season, start_date, end_date, venue, description, status
)
select
  'f61de6a2-cbb9-4ffb-96c7-84a0e98023ca'::uuid,
  'USSA Track & Field Championships',
  2025,
  '2025-05-01'::date,
  '2025-05-03'::date,
  'Pilditch Stadium, Pretoria, South Africa',
  E'CUT athlete performances verified from published final results:\n\nMen''s 5,000m final:\n- Themba Moloi — 11th, 16:00.24\n- Lehlohonolo Khoanyane — 12th, 16:10.61\n\nMen''s Half-Marathon:\n- Ubabalwe Ndima — 15th, 1:18:13\n- Thamsanqa Mbeba — 24th, 1:24:29\n- Mehluli September — 29th, 1:26:09\n- Karabo Rancho — 31st, 1:27:38\n\nThese are individual event results, not an overall CUT team placing. The available published finals do not establish a CUT team championship score or overall position. Source: Backtrack full results (6 May 2025); event dates and venue cross-checked against World Athletics.',
  'completed'
where not exists (
  select 1 from public.competitions
  where sport_id = 'f61de6a2-cbb9-4ffb-96c7-84a0e98023ca'::uuid
    and name = 'USSA Track & Field Championships'
    and season = 2025
);
