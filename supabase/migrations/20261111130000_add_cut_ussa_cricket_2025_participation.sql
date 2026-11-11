-- Record CUT's verified participation in the 2025 USSA Cricket Tournament.
-- No match scores or final placing are added because the source does not publish them.
insert into public.competitions
  (sport_id, name, season, start_date, end_date, venue, description, status)
select s.id, 'USSA Cricket Tournament', '2025',
       date '2025-12-01', date '2025-12-05',
       'Stellenbosch University, Stellenbosch, South Africa',
       'CUT Cricket participated in the USSA Tournament hosted by Stellenbosch University from 1–5 December 2025. Match results, player statistics and final placing were not stated in the available CUT annual report.',
       'completed'
from public.sports s
where s.name = 'Cricket'
  and not exists (
    select 1 from public.competitions c
    where c.sport_id = s.id
      and c.name = 'USSA Cricket Tournament'
      and c.season = '2025'
  );