-- Import verified CUT-associated standings from the 2023/24 Free State ABC Motsepe League.
-- Source: SAFA Activity Report 2024, Free State provincial league tables.
-- No match-level results or player statistics are inferred.

insert into public.competitions
(id, sport_id, name, season, venue, description)
values
('a43e3a9b-7c4e-4d7e-9f7c-2024a5b00001',
 '4c1ccd6f-3965-422a-ad25-19aaa2797f23',
 'ABC Motsepe League — Free State',
 '2023/24',
 'Free State',
 '2023/24 Free State ABC Motsepe League. The SAFA 2024 activity report records Central University of FS seventh in Stream A (18 played, 6 wins, 3 draws, 9 losses, 28 goals for, 29 against, 21 points) and Ixias FC ninth in Stream B (16 played, 2 wins, 5 draws, 9 losses, 14 goals for, 28 against, 11 points). These are league standings only; no match results or individual player statistics are asserted.')
on conflict (id) do nothing;

insert into public.competition_standings
(competition_id, team_name, group_name, position, played, won, drawn, lost, scored, conceded, points_difference, bonus_points, points, source_url)
values
('a43e3a9b-7c4e-4d7e-9f7c-2024a5b00001','Central University of FS','Stream A',7,18,6,3,9,28,29,-1,0,21,'https://fliphtml5.com/dafva/fnps/SAFA_Activity_Report_2024_Flipbook/'),
('a43e3a9b-7c4e-4d7e-9f7c-2024a5b00001','Ixias FC','Stream B',9,16,2,5,9,14,28,-14,0,11,'https://fliphtml5.com/dafva/fnps/SAFA_Activity_Report_2024_Flipbook/')
on conflict (competition_id, team_name, group_name)
do update set position=excluded.position, played=excluded.played, won=excluded.won,
 drawn=excluded.drawn, lost=excluded.lost, scored=excluded.scored,
 conceded=excluded.conceded, points_difference=excluded.points_difference,
 bonus_points=excluded.bonus_points, points=excluded.points, source_url=excluded.source_url,
 source_checked_at=now();
