-- Import CUT Cricket's documented Free State Super League titles.
-- Institutional source: CUT Student Services Information Booklet (2015),
-- "Achievements over the past five years" records champions in 2010 and 2011:
-- https://cms.cut.ac.za/Files/Froala/ca449ad7-330c-43f0-8541-1067703dfa85.pdf
-- Independent confirmation for the 2011/2012 season: OFM, 30 May 2012,
-- reporting CUT won the Super League and qualified for National Club Championships:
-- https://www.ofm.co.za/article/Cricket/117986/Free-State-Cricket-Union-reward-players-and-officials
-- No match scorelines, venue, fixtures or individual player figures are asserted.

insert into public.competitions
  (id, sport_id, name, season, start_date, end_date, venue, description, status)
values
  (
    'a43e3a9b-7c4e-4d7e-9f7c-2010c5a00001',
    '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
    'Free State Super League',
    '2010',
    null,
    null,
    null,
    'CUT Cricket is recorded by the university as Free State Super League champions in 2010. The available institutional achievement record confirms the title but does not provide fixtures, scorelines, standings detail, venue or individual player statistics; these are not asserted.',
    'completed'
  ),
  (
    'a43e3a9b-7c4e-4d7e-9f7c-2011c5a00002',
    '481726ef-be80-4f8e-a0c4-c5f8c41a0f74',
    'Free State Super League',
    '2011',
    null,
    null,
    null,
    'CUT Cricket is recorded by the university as Free State Super League champions in 2011. Free State Cricket Union award coverage also identifies CUT as the Free State Cricket Club Championship representative after winning the Super League for the 2011/2012 season and qualifying for the National Club Championships. The available sources do not provide league fixtures, scorelines, full standings or individual player statistics; these are not asserted.',
    'completed'
  )
on conflict (id) do nothing;
