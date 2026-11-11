-- Record the verified 2024 Free State Sasol League season outcome for CUT Ixias.
-- The league table and two match records were already present; this migration
-- clarifies the season dates and national qualification outcome without
-- replacing historical match or standings data.

update public.competitions
set start_date = '2024-02-01',
    end_date = '2024-09-08',
    venue = 'Free State; provincial final at CUT, Bloemfontein',
    description = '2024 Free State Sasol League women''s season. Ixias FC (CUT) won Group 1A unbeaten: 14 played, 13 wins, 1 draw, 0 losses, 83 goals scored, 1 conceded, 40 points. In the provincial final on 8 September 2024, Ixias drew 1-1 with Kovsies FC; Kovsies won the penalty shoot-out and qualified for the national championship. Ixias therefore did not represent Free State at the 2024 national championship. Kovsies finished third nationally. The recorded 11-0 Ixias win over Napoli Ladies is a league fixture; it is not the provincial final.'
where id = '4e8d727d-d04b-4f0c-a37a-e8baec7ec51c';
