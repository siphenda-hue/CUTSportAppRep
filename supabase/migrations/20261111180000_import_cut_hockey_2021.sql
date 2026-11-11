-- Import verified 2021 USSA Women B-Section CUT hockey record.
-- Source: https://saha.altiusrt.com/competitions/97
with comp as (
  insert into public.competitions
    (sport_id, name, season, start_date, end_date, venue, description, status)
  values
    ('cc6888d8-dd80-470d-9046-2bddf1a6b19a',
     '2021 USSA Women B-Section', '2021', '2021-09-23', '2021-09-27',
     'Johannesburg',
     'CUT finished 2nd overall and 1st in Pool A (3 wins, 1 draw). Official SAHA AltiusRT source: https://saha.altiusrt.com/competitions/97',
     'completed')
  returning id
),
pool_rows(team_name, position, played, won, drawn, lost, scored, conceded, points_difference, points) as (
  values
    ('Central University of Technology', 1, 4, 3, 1, 0, 13, 1, 12, 10),
    ('Tshwane University of Technology', 2, 4, 2, 2, 0, 12, 3, 9, 8),
    ('Sol Plaajie University', 3, 4, 2, 1, 1, 10, 5, 5, 7),
    ('Mangosuthu University of Technology', 4, 4, 0, 1, 3, 1, 9, -8, 1),
    ('Vaal University of Technology', 5, 4, 0, 1, 3, 0, 18, -18, 1)
),
final_rows(team_name, position) as (
  values
    ('Tshwane University of Technology', 1),
    ('Central University of Technology', 2),
    ('Sol Plaajie University', 3),
    ('Mangosuthu University of Technology', 4),
    ('Vaal University of Technology', 5)
),
ins_pool as (
  insert into public.competition_standings
    (competition_id, team_name, group_name, position, played, won, drawn, lost,
     scored, conceded, points_difference, bonus_points, points, source_url, source_checked_at)
  select comp.id, p.team_name, 'Pool A', p.position, p.played, p.won, p.drawn, p.lost,
         p.scored, p.conceded, p.points_difference, 0, p.points,
         'https://saha.altiusrt.com/competitions/97', now()
  from comp cross join pool_rows p
  returning id
),
ins_final as (
  insert into public.competition_standings
    (competition_id, team_name, group_name, position, played, won, drawn, lost,
     scored, conceded, points_difference, bonus_points, points, source_url, source_checked_at)
  select comp.id, f.team_name, 'Final', f.position, 0, 0, 0, 0,
         0, 0, 0, 0, 0,
         'https://saha.altiusrt.com/competitions/97', now()
  from comp cross join final_rows f
  returning id
),
player_rows(player_name, team_name, field_goals, penalty_corner_goals, penalty_stroke_goals, total_goals) as (
  values
    ('BRITZ Tanya', 'Central University of Technology', 5, 2, 0, 7),
    ('IMMELMAN Kara', 'Central University of Technology', 2, 1, 0, 3),
    ('JONES Stacey', 'Central University of Technology', 0, 1, 0, 1),
    ('MOKUNI Lulama', 'Central University of Technology', 1, 0, 0, 1)
),
ins_players as (
  insert into public.competition_player_statistics
    (competition_id, player_name, team_name, field_goals, penalty_corner_goals,
     penalty_stroke_goals, total_goals, source_url, source_checked_at)
  select comp.id, p.player_name, p.team_name, p.field_goals, p.penalty_corner_goals,
         p.penalty_stroke_goals, p.total_goals,
         'https://saha.altiusrt.com/competitions/97', now()
  from comp cross join player_rows p
  returning id
),
team_rows(team_name, field_goals, penalty_corner_goals, penalty_stroke_goals, total_goals) as (
  values
    ('Central University of Technology', 9, 4, 0, 13),
    ('Tshwane University of Technology', 8, 4, 0, 12),
    ('Sol Plaajie University', 8, 2, 0, 10),
    ('Mangosuthu University of Technology', 0, 1, 0, 1),
    ('Vaal University of Technology', 0, 0, 0, 0)
)
insert into public.competition_team_statistics
  (competition_id, team_name, field_goals, penalty_corner_goals, penalty_stroke_goals,
   total_goals, source_url, source_checked_at)
select comp.id, t.team_name, t.field_goals, t.penalty_corner_goals, t.penalty_stroke_goals,
       t.total_goals, 'https://saha.altiusrt.com/competitions/97', now()
from comp cross join team_rows t;