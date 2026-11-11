-- Correct the 2022 USSA Football qualification matches that were previously
-- attached to the 2022 Varsity Sport Cricket competition.
-- Source: CUT report published 14 Dec 2022:
-- https://www.cut.ac.za/news/cut-mens-soccer-team-qualifies-for-the-2023-v

insert into public.competitions
  (id, sport_id, name, season, start_date, end_date, venue, description, status)
values
  ('a43e3a9b-7c4e-4d7e-9f7c-2022f5b00001',
   '4c1ccd6f-3965-422a-ad25-19aaa2797f23',
   'USSA Football Tournament',
   '2022',
   '2022-12-05',
   '2022-12-09',
   'Secunda, Mpumalanga, South Africa',
   'CUT participated in the 2022 USSA Football Tournament. The men defeated the University of Venda 1-0 to secure qualification for the 2023 Varsity Football competition. The women lost 3-4 to the University of KwaZulu-Natal and did not qualify. Match dates and individual scorers are not stated in the available CUT report.',
   'completed')
on conflict (id) do nothing;

update public.competition_matches
set competition_id = 'a43e3a9b-7c4e-4d7e-9f7c-2022f5b00001',
    updated_at = now()
where competition_id = 'a43e3a9b-7c4e-4d7e-9f7c-2022f5a00001'
  and source_match_id in (
    'cut-men-univen-ussa-2022',
    'cut-women-ukzn-ussa-2022'
  );
