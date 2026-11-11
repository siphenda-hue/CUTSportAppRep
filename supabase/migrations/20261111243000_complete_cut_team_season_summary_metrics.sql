update public.competition_team_statistics
set statistics=statistics||jsonb_build_object('final_position',7,'unattributed_goals',3)
where competition_id=(select id from public.competitions where sport_id='4c1ccd6f-3965-422a-ad25-19aaa2797f23' and name='Varsity Football Men' and season='2025' limit 1)
and team_name='CUT';

update public.competition_team_statistics
set statistics=statistics||jsonb_build_object('final_position',8,'relegated_to','FNB Varsity Shield 2027')
where competition_id=(select id from public.competitions where sport_id='83ddd3ad-ceef-4855-8e37-1303e388f58d' and name='FNB Varsity Cup' and season='2026' limit 1)
and team_name='CUT Ixias';