-- Add the verified 2018 Varsity Cricket tournament dates.
-- Contemporary reporting confirms the competition ran from 29 January to 3 February 2018.

update public.competitions
set
  start_date = '2018-01-29',
  end_date = '2018-02-03'
where id = 'a43e3a9b-7c4e-4d7e-9f7c-2018f5a00001'
  and season = '2018'
  and name = 'Varsity Cricket Tournament';
