-- Add CUT's verified Group B standing at the 2025 USSA A Week cricket tournament.
-- CUT played four group fixtures and the Group B third-place play-off:
-- wins over Varsity College and TUT; losses to ETA, UCT and Madibaz B.
-- The source does not publish CUT's full aggregate points or run totals here.

insert into public.competition_standings (
  competition_id, team_name, group_name, position,
  played, won, drawn, lost, source_url
)
select
  'b6bdca69-c0bf-445b-9089-a467b6f357dd',
  'Central University of Technology',
  'Group B',
  4,
  5,
  2,
  0,
  3,
  'https://www.clubcricket.co.za/latestnews/ussa-cricket-week-updates/'
where not exists (
  select 1
  from public.competition_standings
  where competition_id='b6bdca69-c0bf-445b-9089-a467b6f357dd'
    and team_name='Central University of Technology'
);
