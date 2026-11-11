-- Correct the 2024 Women's Varsity Football event window and group metadata.
-- The four existing CUT match results are preserved.
-- Sources: Varsity Sports match reports dated 26-28 July 2024 and the
-- 5th/6th-place playoff report for 29 July 2024.

update public.competitions
set end_date = '2024-07-29',
    description = '2024 Women''s Varsity Football. CUT made its debut and played three Group B matches from 26–28 July, then the 5th/6th-place playoff on 29 July. CUT beat CPUT 1-0, lost 1-6 to UWC and 0-4 to UJ, then lost 0-6 to UP-Tuks in the playoff. CUT finished third in Group B and sixth overall. Match-level scorers are recorded where published; no additional player statistics are inferred.'
where id = 'ff012715-ae52-4b1d-b3a4-d6c528d27112';

update public.competition_matches
set group_name = 'Group B'
where competition_id = 'ff012715-ae52-4b1d-b3a4-d6c528d27112'
  and match_round like 'Group B%';
