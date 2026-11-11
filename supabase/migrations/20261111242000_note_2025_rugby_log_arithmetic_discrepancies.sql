update public.competition_team_statistics
set statistics=statistics||jsonb_build_object('published_log_points_arithmetic_note','The published log shows 3 bonus points and 11 log points after a 5-point deduction; these figures do not fully reconcile under the standard 4-points-per-win calculation. The official published final log points are retained without recalculation.')
where competition_id=(select id from public.competitions where sport_id='83ddd3ad-ceef-4855-8e37-1303e388f58d' and name='FNB Varsity Cup' and season='2025' limit 1)
and team_name='CUT Ixias';

update public.competitions
set description=description||' The source log has arithmetic inconsistencies in points-difference and bonus-point totals; imported points difference values are calculated from points for and against, while published final log points are retained.'
where sport_id='83ddd3ad-ceef-4855-8e37-1303e388f58d' and name='FNB Varsity Cup' and season='2025';