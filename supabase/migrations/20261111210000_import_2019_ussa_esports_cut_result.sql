-- Import the verified inaugural USSA eSports championship result for CUT.
-- Only the institution-level placing is recorded; no player-level results are inferred.
insert into public.competitions
  (id, sport_id, name, season, start_date, end_date, venue, description, status)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2019e5a00001',
   (select id from public.sports where name = 'E-Sport' limit 1),
   'USSA eSports Championships',
   '2019', '2019-09-21', '2019-09-22',
   'Coetzenburg Indoor Sports Centre, Stellenbosch University, Stellenbosch, South Africa',
   'The inaugural USSA eSports tournament was held at Stellenbosch University on 21–22 September 2019. Eleven universities competed in a 2v2 digital football tournament, with each institution fielding eight players across four pairs. CUT eTitans finished 2nd overall, behind Stellenbosch University and ahead of North-West University. Only the verified institutional placing is recorded; individual player names, match scores and game-by-game results are not available in the cited reports. Sources: CUT News, 24 October 2019 https://www.cut.ac.za/news/cut-gaming-students-put-their-skills-to-the-t ; ACGL event report https://acgl.gg/news/The-first-USSA-Esports-Tournament-Kicks-Off ; CUT highlights PDF https://cms.cut.ac.za/Files/Froala/34e448b8-b1d7-468d-a716-c6050cbf8385.pdf',
   'completed')
on conflict (id) do update set
  name=excluded.name, season=excluded.season, start_date=excluded.start_date,
  end_date=excluded.end_date, venue=excluded.venue,
  description=excluded.description, status=excluded.status;

insert into public.competition_standings
  (competition_id, team_name, group_name, position, source_url, source_checked_at)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2019e5a00001',
   'CUT eTitans', 'Overall Team Standing', 2,
   'https://www.cut.ac.za/news/cut-gaming-students-put-their-skills-to-the-t',
   now())
on conflict (competition_id, team_name, group_name) do update set
  position=excluded.position, source_url=excluded.source_url,
  source_checked_at=excluded.source_checked_at, updated_at=now();
