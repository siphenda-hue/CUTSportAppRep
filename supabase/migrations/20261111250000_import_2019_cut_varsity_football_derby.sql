-- Archive the verified 2019 CUT Varsity Football appearance and Bloemfontein derby.
-- Only one sourced fixture is known; this is not a complete season schedule.
with comp as (
  insert into public.competitions
    (id, sport_id, name, season, start_date, end_date, venue, description, status)
  values
    ('a43e3a9b-7c4e-4d7e-9f7c-2019f5b00001'::uuid,
     '4c1ccd6f-3965-422a-ad25-19aaa2797f23'::uuid,
     'Varsity Football Men',
     '2019',
     null,
     null,
     'CUT Football Grounds, Bloemfontein, South Africa',
     'Historical archive: CUT qualified among eight universities from 26 for the 2019 Varsity Football competition. One independently documented fixture is recorded: CUT defeated UFS 2-0 in the first Bloemfontein derby on 15 August 2019. Scorers: Itumeleng Chelopo and Mothusi Madilola. FNB Player of the Match: Mpho Molwatse; Debonairs Pizza Real Deal Save of the Match: Thabo Samuel; MTN Pulse Moment of Brilliance: Oratile Mothibedi. This is a verified historical appearance and match, not a complete season schedule or final standings.',
     'completed')
  on conflict (id) do update set
    description = excluded.description,
    venue = excluded.venue,
    status = 'completed'
  returning id
)
insert into public.competition_matches
  (competition_id, source_match_id, starts_at, home_team, away_team,
   home_score, away_score, match_status, match_round, venue, source_url, statistics)
select
  comp.id,
  'cut-ufs-2019-bloemfontein-derby',
  null, -- match date is known; kickoff time is not
  'CUT',
  'UFS',
  2,
  0,
  'completed',
  'Bloemfontein Derby',
  'CUT Football Grounds, Bloemfontein, South Africa',
  'https://www.cut.ac.za/news/cut-football-subdue-ufs-team-in-first-ever-fr',
  '{"scorers":["Itumeleng Chelopo","Mothusi Madilola"],"fnb_player_of_the_match":"Mpho Molwatse","save_of_the_match":"Thabo Samuel","moment_of_brilliance":"Oratile Mothibedi","kickoff_time_verified":false}'::jsonb
from comp
on conflict (competition_id, source_match_id) do update set
  starts_at = excluded.starts_at,
  home_score = excluded.home_score,
  away_score = excluded.away_score,
  match_status = 'completed',
  match_round = excluded.match_round,
  venue = excluded.venue,
  source_url = excluded.source_url,
  statistics = excluded.statistics,
  updated_at = now();
