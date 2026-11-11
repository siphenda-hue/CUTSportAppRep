-- Add CUT's verified final positions in the 2014 USSA hockey tournaments.
-- CUT's June 2014 Gratia magazine reports men's fourth place and women's
-- second place in the C Section. Unpublished match totals remain unset/default.
insert into public.competition_standings (
  competition_id, team_name, position, source_url
)
select
  v.competition_id,
  'Central University of Technology',
  v.position,
  'https://www.cut.ac.za/wp-content/uploads/2013/04/Gratia-June-2014.pdf'
from (values
  ('b8142014-0000-4000-8000-000000000001'::uuid, 4),
  ('b8142014-0000-4000-8000-000000000002'::uuid, 2)
) as v(competition_id, position)
where not exists (
  select 1
  from public.competition_standings s
  where s.competition_id = v.competition_id
    and s.team_name = 'Central University of Technology'
);
