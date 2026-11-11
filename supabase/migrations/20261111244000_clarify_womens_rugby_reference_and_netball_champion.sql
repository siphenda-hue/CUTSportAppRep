update public.competitions
set description='Women’s university rugby competition. National competition reference only; CUT participation in the 2026 Varsity Cup Women was not verified. No CUT fixtures, results or player statistics are attributed to this record.'
where sport_id='83ddd3ad-ceef-4855-8e37-1303e388f58d' and name='FNB Varsity Cup Women' and season='2026';

update public.competitions
set description=description||' UJ won the 2026 championship with a 56-44 final victory over NWU Eagles on 28 September.'
where sport_id='6c1bd7e1-bd32-4367-8270-d2d0d3c0f3b9' and name='Varsity Netball' and season='2026';