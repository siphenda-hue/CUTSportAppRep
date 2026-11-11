-- Record the 2017 USSA Cricket qualifier result confirmed by contemporary
-- reporting: CUT knocked out UFS (Kovsies) to earn entry to Varsity Cricket.
-- The accessible source does not state the score or exact fixture date.

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
  'a43e3a9b-7c4e-4d7e-9f7c-2017c5a00001',
  'ussa-cricket-2017-cut-vs-ufs-qualifier',
  null,
  'CUT',
  'University of the Free State (Kovsies)',
  null,
  null,
  'completed',
  'USSA Varsity Cricket qualifier',
  'Pretoria, Gauteng, South Africa',
  'https://www.citizen.co.za/rekord/sports-news/local-sports/2018/01/23/varsity-cricket-returns-potchefstroom-nwu-look-reclaim-trophy/',
  '{"result":"CUT knocked out Kovsies in the USSA qualifier","scorecard_available":false}'::jsonb
)
on conflict (competition_id, source_match_id) do update
set
  match_status = excluded.match_status,
  match_round = excluded.match_round,
  venue = excluded.venue,
  source_url = excluded.source_url,
  statistics = excluded.statistics;

update public.competitions
set description = 'CUT Cricket won the USSA Cricket B Section in Pretoria in 2017 and earned promotion to the A Section for 2018. Contemporary reporting also confirms that CUT knocked out the University of the Free State (Kovsies) in the October 2017 USSA qualifier to secure entry to Varsity Cricket 2018. The accessible sources do not provide the qualifier scorecard or exact match date; no other match results or individual player statistics are asserted.'
where id = 'a43e3a9b-7c4e-4d7e-9f7c-2017c5a00001';

commit;
