-- Record the 2024 USSA Cross Country Championships event and verified CUT team result.
-- Individual athlete rows are intentionally excluded unless the athlete already
-- exists in the CUT athlete/statistics database and the official result matches.
insert into public.competitions
  (id, sport_id, name, season, start_date, end_date, venue, description, status)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2024c0550001',
   (select id from public.sports where name = 'Athletics & Cross Country' limit 1),
   'USSA Cross Country Championships',
   '2024', '2024-09-13', '2024-09-14',
   'Nelson Mandela University, South Campus, Gqeberha, Eastern Cape, South Africa',
   'Event date and venue verified by Athletics South Africa event listing and University of Cape Town Athletics Club archive. The competition was held 13–14 September 2024 at Nelson Mandela University, Gqeberha.

CUT participation is confirmed by the official individual result PDFs. In the men''s 4km, CUT athletes placed 42nd (Mmiseni Ngcobo, 13:25), 59th (Bothlale Moncho, 14:44), 68th (Mpho Litaba, 16:19) and 70th (Bongani Yawa, 16:43). In the men''s 10km, CUT athletes placed 7th (Thabang Masihlelo, 32:35), 22nd (Ubabalwe Ndima, 34:40) and 31st (Avela Qutu, 37:02). The official men''s 10km university team competition placed CUT 6th with 60 points. The 4km men''s team competition PDF remained inaccessible during this audit, so no 4km team placing is recorded.

Athlete import restriction: the public.athletes registry currently contains zero profiles. Exact case-insensitive, trimmed-name matching of all seven CUT names from the individual PDFs against existing public.competition_player_statistics records returned zero matches. In accordance with the CUT-only matching rule, no individual athlete statistics or profiles have been created. The verified CUT men''s 10km team placing is recorded separately as a team standing.

The women''s 4km individual results and women''s team sheets reviewed do not show a CUT team entry. The women''s 10km individual PDF timed out during retrieval; its team sheet lists no CUT team. The long mixed relay top-eight teams are Tuks, UJ, NWU Potch, UFS, TUT, Fort Hare, UWC and NMU; CUT is not in that top eight. The short relay result sheet was retrieved, but the visible pages reviewed do not establish a CUT placing.

Sources: UCT Athletics Club archive https://sport.uct.ac.za/athletics-club/cross-country-2024 ; men''s 4km PDF https://sport.uct.ac.za/media/640504 ; men''s 10km PDF https://sport.uct.ac.za/media/640482 ; men''s 10km team competition PDF https://sport.uct.ac.za/media/640481 ; women''s 4km team PDF https://sport.uct.ac.za/media/640487 ; women''s 10km team PDF https://sport.uct.ac.za/media/640480 ; short relay PDF https://sport.uct.ac.za/media/640509 ; long relay PDF https://sport.uct.ac.za/media/640511',
   'completed')
on conflict (id) do update set
  name=excluded.name, season=excluded.season, start_date=excluded.start_date,
  end_date=excluded.end_date, venue=excluded.venue,
  description=excluded.description, status=excluded.status;

insert into public.competition_standings
  (competition_id, team_name, group_name, position, points, source_url, source_checked_at)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2024c0550001',
   'CUT', 'Men 10km Team', 6, 60,
   'https://sport.uct.ac.za/media/640481', now())
on conflict (competition_id, team_name, group_name)
do update set
  position = excluded.position,
  points = excluded.points,
  source_url = excluded.source_url,
  source_checked_at = excluded.source_checked_at,
  updated_at = now();
