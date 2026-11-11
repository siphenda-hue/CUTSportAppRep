-- Import CUT's verified 2022 Red Bull Campus Clutch Valorant participation.
-- The CUT annual report confirms the Free State chapter win and national
-- semi-final appearance, but does not provide player-level or match results.
insert into public.competitions
  (id, sport_id, name, season, start_date, end_date, venue, description, status)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2022e5a00001',
   (select id from public.sports where name = 'E-Sport' limit 1),
   'Red Bull Campus Clutch Valorant',
   '2022', '2022-09-08', '2022-09-25',
   'Free State Chapter qualifier; Comic Con Africa, Johannesburg, South Africa',
   'CUT participated in the 2022 Red Bull Campus Clutch Valorant competition. The CUT 2022 Annual Report records that CUT entered three teams, won the Free State Chapter, and represented the province at the national finals held at Comic Con Africa in Johannesburg from 22–25 September 2022. CUT is reported to have reached the semi-final stage in Johannesburg. The report does not provide a final numeric national placing, match scores, player names or individual statistics; none are inferred or imported. Source: CUT 2022 Annual Report, section 6.14.5, page 282 https://cms.cut.ac.za/Files/Froala/a331d2a8-5ca9-493d-85dd-a942791a1a64.pdf ; national finals dates and event context: https://iol.co.za/saturday-star/news/2022-09-21-red-bull-campus-clutch-national-finals-taking-place-at-comic-con-africa-this-weekend/',
   'completed')
on conflict (id) do update set
  name=excluded.name, season=excluded.season, start_date=excluded.start_date,
  end_date=excluded.end_date, venue=excluded.venue,
  description=excluded.description, status=excluded.status;

insert into public.competition_standings
  (competition_id, team_name, group_name, position, source_url, source_checked_at)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2022e5a00001',
   'CUT', 'Free State Chapter', 1,
   'https://cms.cut.ac.za/Files/Froala/a331d2a8-5ca9-493d-85dd-a942791a1a64.pdf',
   now())
on conflict (competition_id, team_name, group_name) do update set
  position=excluded.position, source_url=excluded.source_url,
  source_checked_at=excluded.source_checked_at, updated_at=now();
