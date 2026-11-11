update public.competitions
set start_date='2025-06-30',end_date='2025-07-04',venue='Nelson Mandela University, Gqeberha',
    description='CUT finished 8th in the A Section at the 2025 USSA National Netball Tournament (30 June–4 July, Nelson Mandela University), qualifying for its Varsity Netball debut in 2026.'
where sport_id='6c1bd7e1-bd32-4367-8270-d2d0d3c0f3b9' and name='USSA Netball Championships' and season='2025';

update public.competition_team_statistics
set statistics=statistics||jsonb_build_object('final_position',8,'division','A Section','tournament_dates','2025-06-30 to 2025-07-04')
where competition_id=(select id from public.competitions where sport_id='6c1bd7e1-bd32-4367-8270-d2d0d3c0f3b9' and name='USSA Netball Championships' and season='2025' limit 1)
and team_name='CUT';