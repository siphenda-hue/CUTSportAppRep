-- Record CUT's verified qualification for the 2026 Varsity Esports Split 2 Finals.
-- The source confirms CUT's Rocket League finalist, not the final placing.
insert into public.competitions
  (id, sport_id, name, season, start_date, end_date, venue, description, status)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2026e5a00001',
   (select id from public.sports where name = 'E-Sport' limit 1),
   'Varsity Esports Split 2',
   '2026', '2026-10-02', '2026-10-03',
   'Rembrandt Hall, University of Pretoria, Pretoria, South Africa',
   'CUT qualified for the 2026 Varsity Esports Split 2 Finals in Rocket League. The official Varsity Sports announcement names SuperNova as the team representing Central University of Technology among the four Rocket League finalists. The announcement confirms finalist qualification only; no final placing, match score or player statistics are asserted here. Event dates were 2–3 October 2026 at UP-Tuks. Sources: Varsity Sports, “Varsity Esports Split 2 Finalists Confirmed” https://www.varsitysportssa.com/post/varsity-esports-split-2-finalists-confirmed ; Varsity Esports 2026 Split 2 event information https://varsityesports.co.za/news/varsity-esports-2026-split-2-finals-qualifications-currently-underway-as-competition-heads-to-pretoria',
   'completed')
on conflict (id) do update set
  name=excluded.name, season=excluded.season, start_date=excluded.start_date,
  end_date=excluded.end_date, venue=excluded.venue,
  description=excluded.description, status=excluded.status;

insert into public.competition_standings
  (competition_id, team_name, group_name, position, source_url, source_checked_at)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2026e5a00001',
   'SuperNova (CUT)', 'Rocket League – Split 2 Finalist', null,
   'https://www.varsitysportssa.com/post/varsity-esports-split-2-finalists-confirmed',
   now())
on conflict (competition_id, team_name, group_name) do update set
  position=excluded.position, source_url=excluded.source_url,
  source_checked_at=excluded.source_checked_at, updated_at=now();
