-- Import the verified 2018 Varsity Cricket group-stage result involving CUT.
-- UP-Tuks' 2017/18 season report confirms Tuks beat CUT with a bonus point.
-- The report does not provide the match score or exact date, so both remain null.

begin;

insert into public.competition_matches (
  competition_id,
  source_match_id,
  starts_at,
  home_team,
  away_team,
  home_score,
  away_score,
  match_status,
  match_round,
  venue,
  source_url,
  statistics
)
values (
  'a43e3a9b-7c4e-4d7e-9f7c-2018f5a00001',
  'varsity-cricket-2018-up-tuks-vs-cut',
  null,
  'UP-Tuks',
  'CUT',
  null,
  null,
  'completed',
  'Group stage',
  'Potchefstroom, North West, South Africa',
  'https://www.up.ac.za/media/shared/277/ZP_Files/2018/newsletters/2018-newsletter-issue-1.zp148184.pdf',
  '{"result":"UP-Tuks won with a bonus point","scorecard_available":false}'::jsonb
)
on conflict (competition_id, source_match_id) do update
set
  match_status = excluded.match_status,
  match_round = excluded.match_round,
  venue = excluded.venue,
  source_url = excluded.source_url,
  statistics = excluded.statistics;

update public.competitions
set description = 'CUT Cricket qualified for and participated in the 2018 Varsity Cricket competition in Potchefstroom. UP-Tuks’ 2017/18 season report confirms that Tuks defeated CUT with a bonus point during the group stage. The accessible report does not provide the match score or exact date, and no final placing for CUT is asserted.'
where id = 'a43e3a9b-7c4e-4d7e-9f7c-2018f5a00001';

commit;
