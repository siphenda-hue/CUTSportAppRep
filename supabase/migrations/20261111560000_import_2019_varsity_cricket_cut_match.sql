-- Import the verified 2019 Varsity Cricket group-stage result involving CUT.
-- UP-Tuks' report confirms a six-wicket win over CUT but does not publish
-- the scorecard or exact match date; those fields are intentionally left null.

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
  'a43e3a9b-7c4e-4d7e-9f7c-2019f5a00001',
  'varsity-cricket-2019-cut-vs-up-tuks',
  null,
  'UP-Tuks',
  'CUT',
  null,
  null,
  'completed',
  'Group stage',
  'Senwes Park, Potchefstroom',
  'https://www.up.ac.za/cricket/news/post_2837442-assupol-tukscricket-assupol-tuks-on-track-to-defend-their-varsity-cricket-title',
  '{"result":"UP-Tuks won by six wickets","scorecard_available":false}'::jsonb
)
on conflict (competition_id, source_match_id) do update
set
  match_status = excluded.match_status,
  match_round = excluded.match_round,
  venue = excluded.venue,
  source_url = excluded.source_url,
  statistics = excluded.statistics;

update public.competitions
set description = 'CUT Cricket participated in the 2019 Varsity Sport Cricket Competition hosted at North-West University in Potchefstroom from 1–7 September 2019. A University of Pretoria report confirms UP-Tuks defeated CUT by six wickets in a group-stage match; the accessible report does not provide the scorecard or exact match date. No final placing is asserted.'
where id = 'a43e3a9b-7c4e-4d7e-9f7c-2019f5a00001';

commit;
