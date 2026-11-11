-- Verified CUT Ixias individual try totals for the 2023 FNB Varsity Cup.
-- Sources: CUT, Varsity Cup, OFM and match reporting cited in the accompanying development notes.
-- The player-level totals include the promotion/relegation match against NMU Madibaz.
with verified_players (
  player_name, total_tries, match_breakdown, awards, name_variants, source_url
) as (
  values
  ('Tokelo Ntaopane', 4, '{"Round 1":3,"Round 2":1}'::jsonb, '[]'::jsonb, '["Tokelo Ntapane"]'::jsonb, 'https://www.cut.ac.za/news/first-home-game-in-the-varsity-cup-2023-for-t'),
  ('Zachery Bester', 5, '{"Round 1":1,"Round 4":2,"Promotion/Relegation Play-off":2}'::jsonb, '[]'::jsonb, '["Zachary Bester","Zac Bester"]'::jsonb, 'https://www.cut.ac.za/news/first-home-game-in-the-varsity-cup-2023-for-t'),
  ('Ulrich Stander', 3, '{"Round 1":1,"Round 3":1,"Round 7":1}'::jsonb, '[]'::jsonb, '[]'::jsonb, 'https://www.studentnews.africa/2023/04/varsity-cup-round-7-results/'),
  ('Thabiso Mkhwebane', 1, '{"Round 1":1}'::jsonb, '[]'::jsonb, '[]'::jsonb, 'https://www.cut.ac.za/news/first-home-game-in-the-varsity-cup-2023-for-t'),
  ('Matthew Sekele', 4, '{"Round 1":1,"Round 4":1,"Round 5":1,"Promotion/Relegation Play-off":1}'::jsonb, '[]'::jsonb, '["Maboe Sekele","Matthew M. Maboe Sekele"]'::jsonb, 'https://www.cut.ac.za/news/first-home-game-in-the-varsity-cup-2023-for-t'),
  ('Asekho Marubelela', 2, '{"Round 2":1,"Round 5":1}'::jsonb, '[]'::jsonb, '["Asekho Marubela"]'::jsonb, 'https://www.cut.ac.za/news/cut-fnb-ixias-emerge-victorious-against-fnb-m'),
  ('Jandre de Beer', 5, '{"Round 3":1,"Round 5":1,"Round 6":2,"Promotion/Relegation Play-off":1}'::jsonb, '[{"award":"FNB Player That Rocks","round":"Round 3"}]'::jsonb, '["Jandré de Beer"]'::jsonb, 'https://www.varsitycup.co.za/news/fnb-varsity-cup-matchday-3-wrap-cut-upset-tuks-victories-for-maties-shimlas-and-uj'),
  ('Francois Bester', 2, '{"Round 3":2}'::jsonb, '[]'::jsonb, '[]'::jsonb, 'https://www.varsitycup.co.za/news/fnb-varsity-cup-matchday-3-wrap-cut-upset-tuks-victories-for-maties-shimlas-and-uj'),
  ('Daniel Venter', 1, '{"Round 3":1}'::jsonb, '[]'::jsonb, '[]'::jsonb, 'https://www.varsitycup.co.za/news/fnb-varsity-cup-matchday-3-wrap-cut-upset-tuks-victories-for-maties-shimlas-and-uj'),
  ('Ricoman Titus', 4, '{"Round 4":3,"Promotion/Relegation Play-off":1}'::jsonb, '[]'::jsonb, '["Titus Ricoman"]'::jsonb, 'https://www.cut.ac.za/news/fnb-cut-ixias-are-victorious-in-away-game-aga'),
  ('Jacobus Cloete', 3, '{"Round 4":1,"Round 5":1,"Promotion/Relegation Play-off":1}'::jsonb, '[{"award":"FNB Player That Rocks","round":"Round 4"}]'::jsonb, '["Jacobus Johannes Cloete"]'::jsonb, 'https://www.cut.ac.za/news/fnb-cut-ixias-are-victorious-in-away-game-aga'),
  ('Janco Cloete', 2, '{"Round 6":2}'::jsonb, '[]'::jsonb, '[]'::jsonb, 'https://www.varsitycup.co.za/news/matchday-6-wrap-wits-relegate-tuks-to-shield-solid-victories-for-nwu-shimlas-and-uj'),
  ('Adielson Gouveia', 1, '{"Round 7":1}'::jsonb, '[]'::jsonb, '[]'::jsonb, 'https://www.studentnews.africa/2023/04/varsity-cup-round-7-results/'),
  ('Tiaan Drotskie', 1, '{"Round 7":1}'::jsonb, '[]'::jsonb, '[]'::jsonb, 'https://www.studentnews.africa/2023/04/varsity-cup-round-7-results/'),
  ('Sisipho Nofuya', 1, '{"Round 7":1}'::jsonb, '[]'::jsonb, '[]'::jsonb, 'https://www.studentnews.africa/2023/04/varsity-cup-round-7-results/'),
  ('Kevin Strydom', 1, '{"Promotion/Relegation Play-off":1}'::jsonb, '[]'::jsonb, '[]'::jsonb, 'https://www.varsitycup.co.za/news/cut-thump-madibaz-to-remain-in-varsity-cup'),
  ('Xavier Swartbooi', 1, '{"Promotion/Relegation Play-off":1}'::jsonb, '[{"award":"FNB Player That Rocks","round":"Round 2"}]'::jsonb, '[]'::jsonb, 'https://www.cut.ac.za/news/cut-fnb-ixias-emerge-victorious-against-fnb-m'),
  ('Jan Bessenger', 1, '{"Promotion/Relegation Play-off":1}'::jsonb, '[]'::jsonb, '["Jan Hendrik Bessenger"]'::jsonb, 'https://www.varsitycup.co.za/news/cut-thump-madibaz-to-remain-in-varsity-cup'),
  ('Trevino Swartz', 1, '{"Promotion/Relegation Play-off":1}'::jsonb, '[]'::jsonb, '[]'::jsonb, 'https://www.varsitycup.co.za/news/cut-thump-madibaz-to-remain-in-varsity-cup'),
  ('Mamello Moshoaliba', 1, '{"Round 6":1}'::jsonb, '[]'::jsonb, '[]'::jsonb, 'https://www.varsitycup.co.za/news/matchday-6-wrap-wits-relegate-tuks-to-shield-solid-victories-for-nwu-shimlas-and-uj')
)
insert into public.competition_player_statistics (
  competition_id, player_name, team_name, total_goals, source_url, source_checked_at, statistics
)
select
  '6c5ed0f1-9c0f-4bbf-910e-e40ccc3772ac'::uuid,
  p.player_name,
  'CUT Ixias',
  p.total_tries,
  p.source_url,
  now(),
  jsonb_build_object(
    'sport', 'Rugby Union',
    'statistic_type', 'tries',
    'total_tries', p.total_tries,
    'match_breakdown', p.match_breakdown,
    'awards', p.awards,
    'source_name_variants', p.name_variants,
    'verification_status', 'source-verified'
  )
from verified_players p
where not exists (
  select 1
  from public.competition_player_statistics existing
  where existing.competition_id = '6c5ed0f1-9c0f-4bbf-910e-e40ccc3772ac'::uuid
    and existing.team_name = 'CUT Ixias'
    and existing.player_name = p.player_name
);
